#!/bin/bash

# Usage: ./create_table2.sh tableName

tableName="$1"
tablePath="databases/$currentDb/$tableName"
schemaPath="databases/$currentDb/${tableName}_Schema"

# Include datatype checker
source ./datatype.sh

# Array to store column names
typeset -a columnArray
typeset -A dataTypeArray

# ========== FUNCTIONS ==========

function checkColumn {
    repeatFlag=0
    dataTypeIsExist=0

    for i in "${columnArray[@]}"; do
        if [ "$i" == "$1" ]; then
            repeatFlag=1
            break
        fi
    done

    source ./datatype.sh "check" "$2"
    dataTypeIsExist=$?
}

function insertColumn {
    local tableName="$1"
    echo -e "📌 Number of columns: \c"
    read columnsNumber
    index=0

    if [[ "$columnsNumber" =~ ^[0-9]+$ ]]; then
        while (( index < columnsNumber )); do
            (( tracker = index + 1 ))
            echo -e "📝 Enter Column $tracker Name: \c"
            read column
            echo -e "🔤 Enter Data Type: \c"
            read dataType

            checkColumn "$column" "$dataType"

            if [ "$repeatFlag" -eq 1 ]; then
                echo "❌ Column '$column' already exists. Try another name."
            elif [ "$dataTypeIsExist" -ne 0 ]; then
                echo "❌ Invalid datatype. Please choose again."
            else
                columnArray[$index]="$column"
                dataTypeArray["$column"]="$dataType"
                echo -ne "$column,$dataType," >> "$schemaPath"
                (( index++ ))
            fi
        done
    else
        echo "❌ Invalid number. Try again."
        insertColumn "$tableName"
    fi

    addPrimary "$tableName"
}

function addPrimary {
    local tableName="$1"
    echo -e "\n🔑 Enter Primary Key column: \c"
    read primaryKey
    isExistFlag=0

    for i in "${columnArray[@]}"; do
        if [ "$i" == "$primaryKey" ]; then
            isExistFlag=1
            break
        fi
    done

    if [ "$isExistFlag" -eq 1 ]; then
        echo -e "$primaryKey" >> "$schemaPath"
        
        # ✅ هنا التعديل: نكتب اسم الجدول عادي متفصل بـ ,
        tableDef="$tableName"
        for col in "${columnArray[@]}"; do
            dt=$(grep "$col," "$schemaPath" | cut -d',' -f2)
            tableDef+=",$col,$dt"
        done
        tableDef+=",$primaryKey"

        echo "$tableDef" >> "databases/$currentDb/Schema"
        echo "✅ Primary key '$primaryKey' set successfully!"
    else
        echo "❌ '$primaryKey' is not one of the columns. Try again."
        addPrimary "$tableName"
    fi
}


# ========== MAIN LOGIC ==========

touch "$tablePath" 2>>./.error.log
touch "$schemaPath" 2>>./.error.log

echo "✅ Table '$tableName' Successfully Created!"

insertColumn "$tableName"

./submenu.sh 2
exit 0
