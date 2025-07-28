#!/bin/bash

function update {
    read -p "Enter Table Name: " tbName
    [[ -z $tbName ]] && echo "You must enter a valid name" && ./submenu.sh 2 && exit

    source ./listTable.sh "call" "$tbName"
    [[ $tableExist -eq 0 ]] && echo "Table does not exist" && ./submenu.sh 2 && exit

    select choice in "Update Table (Add Column)" "Update Rows" "Exit"; do
        case $REPLY in
            1) addColumn; break ;;
            2) updateRowData; break ;;
            3) ./submenu.sh 2; exit ;;
            *) echo "Invalid option";;
        esac
    done
}

function addColumn {
    read -p "Enter New Column Name: " columnName
    read -p "Enter Column Data Type (int/varchar/string): " columnType
    source ./dataType.sh "check" "$columnType"

    # Check if column already exists
    if grep -qw "$columnName" databases/$currentDb/${tbName}_Schema; then
        echo "Column already exists"
        return
    fi

    [[ $dataTypeIsExist -eq 0 ]] && echo "Invalid data type" && return

    # Append column to schema
    sed -i "s/$/,${columnName},${columnType}/" databases/$currentDb/${tbName}_Schema
    sed -i "/^$tbName,/s/$/,${columnName},${columnType}/" databases/$currentDb/Schema

    # Update rows with placeholder value (e.g., NULL)
    awk -F',' -v OFS=',' '{print $0, "NULL", "NULL"}' databases/$currentDb/$tbName > temp && mv temp databases/$currentDb/$tbName

    echo "Column '$columnName' added to table '$tbName'."
    ./submenu.sh 2
    exit
}

function updateRowData {
    read -p "Enter Column Name to Update: " columnName
    read -p "Enter Previous Value: " prevValue
    read -p "Enter New Value: " newValue

    # Get column position
    colPos=$(awk -F',' -v name="$columnName" '{
        for (i=1; i<=NF; i++) if ($i == name) { print i; exit }
    }' databases/$currentDb/${tbName}_Schema)

    [[ -z $colPos ]] && echo "Column not found" && return

    # Validate data type
    columnType=$(awk -F',' -v idx="$colPos" '{print $(idx+1)}' databases/$currentDb/${tbName}_Schema)
    source ./dataType.sh "checkUserInput" "$newValue" "$columnType"
    [[ $userInputDatatype -ne 1 ]] && echo "Invalid data type for new value" && return

    # Update all matching values
    awk -F',' -v OFS=',' -v col="$columnName" -v old="$prevValue" -v new="$newValue" '
    {
        for (i = 1; i <= NF; i++) {
            if ($i == col && $(i+1) == old) {
                $(i+1) = new
            }
        }
        print
    }' databases/$currentDb/$tbName > temp && mv temp databases/$currentDb/$tbName

    echo "Value(s) updated successfully."
    ./submenu.sh 2
    exit
}

update