#!/bin/bash

# Delete Rows
function deleteRow {
    read -rp "Enter Table Name: " tbName
    tbName=$(echo "$tbName" | xargs)

    if [ -z "$tbName" ]; then
        echo "Error: empty input"
        echo "Back to table menu..."
        sleep 2
        clear
        ./submenu.sh 2
        exit
    fi

    tablePath="databases/$currentDb/$tbName"
    schemaPath="databases/$currentDb/${tbName}_Schema"

    if [[ ! -f "$tablePath" ]]; then
        echo "Error: table does not exist"
        echo "Back to table menu..."
        sleep 2
        clear
        ./submenu.sh 2
        exit
    fi

    PS3="hosql-${tbName}> "

    echo
    echo "Choose action for table '$tbName':"
    echo

    select choice in "Delete All Data" "Delete Special Rows" "Exit"; do
        case $REPLY in
            1)
                # truncate (delete all)
                > "$tablePath"
                echo "All rows in '$tbName' have been deleted."
                echo "Back to table menu..."
                sleep 2
                clear
                ./submenu.sh 2
                exit
                ;;
            2)
                delete_special_rows "$tbName"
                echo "Back to table menu..."
                sleep 2
                clear
                ./submenu.sh 2
                exit
                ;;
            3)
                echo "Exiting delete mode, back to previous menu..."
                sleep 1
                clear
                ./submenu.sh 2
                exit
                ;;
            *)
                echo "Invalid option. Choose 1, 2, or 3."
                ;;
        esac
    done
}

function delete_special_rows {
    local tbName="$1"

    read -rp "Enter Column Name: " columnName
    columnName=$(echo "$columnName" | xargs)

    # read schema line and strip trailing comma
    schemaLine=$(head -n1 "databases/$currentDb/${tbName}_Schema" | sed 's/,$//')
    IFS=',' read -ra parts <<< "$schemaLine"

    # find column position (1-based in data rows)
    colIndex=-1
    for ((i=0; i<${#parts[@]}; i+=2)); do
        if [[ "${parts[i]}" == "$columnName" ]]; then
            colIndex=$((i/2 + 1))
            break
        fi
    done

    if [[ $colIndex -eq -1 ]]; then
        echo "Invalid column"
        return
    fi

    read -rp "Enter Column Value: " columnValue
    columnValue=$(echo "$columnValue" | xargs)

    # find matching lines
    mapfile -t toDelete < <(awk -F, -v idx="$colIndex" -v val="$columnValue" '
        function trim(s){ gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
        {
            if (trim($idx) == val) print NR
        }' "databases/$currentDb/$tbName")

    if [ ${#toDelete[@]} -eq 0 ]; then
        echo "No matching rows found."
        return
    fi

    # delete those lines
    sedExpr=""
    for ln in "${toDelete[@]}"; do
        sedExpr+="${ln}d;"
    done
    sedExpr=${sedExpr%;}

    sed -i "$sedExpr" "databases/$currentDb/$tbName"
    echo "Rows with value '$columnValue' in column '$columnName' deleted."
}

deleteRow
