#!/bin/bash

# -------- Check table existence --------
function checkTableExistance() {
    while true; do
        echo -e "Enter table name: \c"
        read tbName

        if [ -z "$tbName" ]; then
            echo "❌ Error: empty input"
            echo "🔙 Back to table menu"
            ./submenu.sh 2
            exit
        fi

        tblIsExist=0

        while IFS=',' read -r tableName _; do
            if [ "$tableName" = "$tbName" ]; then 
                tblIsExist=1
                break
            fi
        done < "databases/$currentDb/Schema"

        if [ $tblIsExist -eq 1 ]; then
            PS3="hosql-${tbName}> "
            break
        else
            echo "❌ Error: Table '$tbName' does not exist."
            echo ""
            echo "What would you like to do?"
            select choice in "📦 Create Table '$tbName'" "🔁 Try another table name" "🔙 Back to previous menu"; do
                case $REPLY in
                    1)
                        echo "Creating table '$tbName'..."
                        ./create_table2.sh "$tbName"
                        PS3="hosql-${tbName}> "
                        return
                        ;;
                    2) break ;;
                    3) ./submenu.sh 2; exit ;;
                    *) echo "⚠️ Invalid choice, please choose 1, 2, or 3." ;;
                esac
            done
        fi
    done
}
checkTableExistance

# -------- Count Table Fields --------
typeset fieldsArray[2]
typeset dataTypeArray[2]
function countTableField {
    fieldLoopCounter=$(awk -F, '{ print NF }' databases/$currentDb/${tbName}_Schema 2>>./.error.log)

    ((fieldCounter=1))
    ((arrayCounter=0))
    for ((j=0;j<"$fieldLoopCounter";j++)); do
        i=$(cut -f$fieldCounter -d, databases/$currentDb/${tbName}_Schema)
        if [[ $i != "int" && $i != "varchar" && $i != "string" ]]; then
            fieldsArray[$arrayCounter]=$i
        else
            dataTypeArray[$arrayCounter]=$i
            ((arrayCounter++))
        fi
        ((fieldCounter++))
    done
    ((arrayCounter++))
}
countTableField

# -------- Insert function --------
function insert
{
    select choice in "Insert Column" "Exit"
    do
        case $choice in
            "Insert Column")
                if [ $primaryKeyIsInserted -eq 0 ]; then 
                    insertPrimaryKey
                else
                    echo -e "Insert column name: \c"
                    read clmnName
                    if [ -z "$clmnName" ]; then
                        echo "❌ Empty input"
                        echo "1️⃣ Try again"
                        echo "2️⃣ Back to table menu"
                        echo -e "Enter your choice [1 or 2]: \c"
                        read choice
                        case $choice in
                            1) continue ;;
                            2) ./submenu.sh 2; exit ;;
                            *) echo "❌ Invalid choice" ;;
                        esac
                    else
                        checkClmn "$clmnName"
                    fi
                fi   

                valueCounter=0
                for ((i=1; i<rowDataCounter; i+=2)); do
                    if [ -n "${rowData[i]}" ]; then
                        ((valueCounter++))
                    fi
                done

                if [ "$valueCounter" -eq "$arrayCounter" ]; then
                    # ✅ الصف اتملّى بالكامل، نحفظه
                    for ((i=0; i<rowDataCounter-1; i+=2)); do
                        echo -n "${rowData[i+1]}," >> databases/$currentDb/$tbName
                    done
                    echo "${rowData[((rowDataCounter-1))]}" >> databases/$currentDb/$tbName

                    echo "✅ Row inserted successfully."
                    echo "🔙 Back to table menu"
                    ./submenu.sh 2
                    exit
                fi
                ;;
            
            "Exit")
                echo "🔙 Back to table menu"
                ./submenu.sh 2
                exit
                ;;
            
            *)
                echo "❌ Invalid choice"
                ;;
        esac
    done
}

# -------- Primary Key Insertion --------
primaryKeyIsInserted=0
function insertPrimaryKey {
    echo -e "put the primary key value first: \c"
    echo -e "${fieldsArray[((arrayCounter-1))]}: \c"
    read primaryKey
    if [ -z "$primaryKey" ]; then
        echo "❌ Error, empty input"
        return
    fi
    for i in $(awk -F, '{print $NF}' databases/$currentDb/$tbName 2>>./.error.log); do
        if [ "$primaryKey" = "$i" ]; then
            echo "❌ Error, primary key exists"
            return
        fi
    done
    checkDataType "$primaryKey" "${fieldsArray[((arrayCounter-1))]}"
    if [ $userInputDatatype -eq 1 ]; then
        insertValue "$primaryKey"
    else
        echo "❌ Wrong datatype"
    fi 
}

# -------- Check column name validity --------
function checkClmn {
    ((clmnIsExist=0))
    for ((i=0; i<"$fieldLoopCounter"; i++)); do
        if [[ $1 == ${fieldsArray[i]} ]]; then
            ((clmnIsExist=1))
            break
        fi
    done

    if [ $clmnIsExist -eq 0 ]; then 
        echo "❌ Column does not exist."
        return
    fi

    while true; do
        echo -e "Insert value: \c"
        read clmnValue
        clmnValue=$(echo "$clmnValue" | xargs)

        if [[ -z "$clmnValue" ]]; then
            echo -e "\n⚠️ Empty value detected."
            echo "1️⃣ Try again"
            echo "2️⃣ Back to table menu"
            echo -e "Enter your choice [1 or 2]: \c"
            read choice
            case $choice in
                1) continue ;;
                2) echo "🔙 Returning to menu..."; ./submenu.sh 2; exit 0 ;;
                *) echo "❌ Invalid choice. Please enter 1 or 2." ;;
            esac
        else
            insertValue "$clmnValue"
            break
        fi
    done
}

# -------- Insert value into array --------
typeset rowData[2]
function insertValue {
    rowDataCounter=0
    if [ $primaryKeyIsInserted -eq 0 ]; then
        for ((i=0; i<arrayCounter; i++)); do
            rowData[$rowDataCounter]=${fieldsArray[i]}
            if [ "${fieldsArray[((arrayCounter-1))]}" = "${fieldsArray[i]}" ]; then 
                rowData[((rowDataCounter+1))]=$primaryKey
            else
                rowData[((rowDataCounter+1))]=""
            fi
            ((rowDataCounter+=2))
        done
        primaryKeyIsInserted=1
    else
        checkDataType "$clmnValue" "$clmnName"
        if [ $userInputDatatype -eq 0 ]; then
            echo "❌ Error, wrong datatype"
            return 
        fi 
        for ((i=0; i<arrayCounter; i++)); do
            rowData[$rowDataCounter]=${fieldsArray[i]}
            if [ "$clmnName" = "${fieldsArray[i]}" ]; then 
                rowData[((rowDataCounter+1))]=$clmnValue
            fi
            ((rowDataCounter+=2))
        done
    fi    
}

# -------- Data type check --------
function checkDataType {
    for ((i=0; i<arrayCounter; i++)); do
        if [ "$2" = "${fieldsArray[$i]}" ]; then 
            dataTypeEntered=${dataTypeArray[$i]}
            break
        fi 
    done
    source ./datatype.sh "checkUserInput" "$1" "$dataTypeEntered"
}

# -------- Start Insertion --------
insert
