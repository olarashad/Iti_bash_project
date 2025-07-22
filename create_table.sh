#!/bin/bash

#Create Table
function createTable {
    while true; do
        echo -e "Enter Unique Table Name: \c"
        read tableName

        # Check if empty
        if [ -z "$tableName" ]; then
            echo "❌ You Must Enter a Valid Name."
            continue
        fi

        tablePath="databases/$currentDb/$tableName"
        schemaPath="databases/$currentDb/${tableName}_Schema"

        # Check if table already exists
        if [ -f "$tablePath" ] || [ -f "$schemaPath" ]; then
            echo "⚠️ Table '$tableName' already exists!"
            echo "What do you want to do?"
            echo "1) Try another name"
            echo "2) Return to submenu"
            read -rp "Choose [1-2]: " choice

            case "$choice" in
                1)
                    continue
                    ;;
                2)
                    ./submenu.sh 2
                    exit 0
                    ;;
                *)
                    echo "Invalid option. Returning to main menu."
                    ./submenu.sh 2
                    exit 1
                    ;;
            esac
        else
            # Create Table files
            touch "$tablePath" 2>>./.error.log
            touch "$schemaPath" 2>>./.error.log
            echo -e "$tableName,\c" >> databases/$currentDb/Schema

            echo "✅ Table '$tableName' Successfully Created!"
            insertCoulmn "$tableName"
            ./submenu.sh 2
            exit 0
        fi
    done
}


# Insert Column
function insertCoulmn {
    local tableName="$1"
    echo -e "Number of columns: \c"
    read columnsNumber
    index=0

    if [[ "$columnsNumber" =~ ^[0-9]+$ ]]; then
        while (( index < columnsNumber )); do
            (( tracker = index + 1 ))
            echo -e "Enter Column $tracker: \c"
            read column
            echo -e "Enter DataType: \c"
            read dataType

            checkColumn "$column" "$dataType"

            if [ "$repeatFlag" -eq 1 ]; then
                echo "❌ Duplicate column name: $column"
            elif [ "$dataTypeIsExist" -eq 0 ]; then
                echo "❌ Invalid datatype"
            else
                columnArray[$index]="$column"
                echo -e "$column,$dataType,\c" >> databases/$currentDb/${tableName}_Schema
                echo -e "$column,$dataType,\c" >> databases/$currentDb/Schema
                (( index++ ))
            fi
        done
    else
        echo "❌ Please enter a valid number"
        insertCoulmn
    fi

    addPrimary
}

# Check Column
typeset columnArray[2]
function checkColumn {
    repeatFlag=0
    for i in "${columnArray[@]}"; do
        if [ "$i" == "$1" ]; then
            repeatFlag=1
            break
        fi
    done
    source ./datatype.sh "check" "$2"
}

# Add Primary Key
function addPrimary {
    echo -e "Enter Primary Key: \c"
    read primaryKey
    isExistFlag=0

    for i in "${columnArray[@]}"; do
        if [ "$i" == "$primaryKey" ]; then
            isExistFlag=1
            break
        fi
    done

    if [ "$isExistFlag" -eq 0 ]; then
        echo "❌ Invalid column name. Please try again."
        addPrimary
    else
        echo -e "$primaryKey" >> databases/$currentDb/${tableName}_Schema
        echo -e "$primaryKey" >> databases/$currentDb/Schema
        echo "✅ Primary key '$primaryKey' set successfully!"
        
    
    fi
}

createTable
