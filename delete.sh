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

delete_special_rows() {
  local tbName="$1"
  local tablePath="databases/$currentDb/$tbName"

  if [[ ! -f "$tablePath" ]]; then
    echo "Table file not found: $tablePath"
    return 1
  fi

  read -rp "Enter key to match (e.g. movie-name): " key
  read -rp "Enter value to delete for that key: " value

tmp=$(mktemp)

while IFS= read -r line; do
  IFS=',' read -ra fields <<< "$line"
  match_found=false

  for ((i=0; i<${#fields[@]}; i+=2)); do
    k="${fields[i]}"
    v="${fields[i+1]}"
    if [[ "$k" == "$key" && "$v" == "$value" ]]; then
      match_found=true
      break
    fi
  done

  if ! $match_found; then
    echo "$line"
  fi
done < "$tablePath" > "$tmp"

mv "$tmp" "$tablePath"
echo "All lines where '$key' == '$value' have been deleted."

}



deleteRow
