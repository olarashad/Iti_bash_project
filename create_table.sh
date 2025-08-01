#!/bin/bash

function pause_back_to_submenu {
    read -rp $'\nPress Enter to go back to the previous menu...' _
    clear
    ./submenu.sh 2
    exit
}

function createTable {
    echo -e "Enter Unique Table Name: \c"
    read tableName

    if [ -z "$tableName" ]; then
        echo "You must enter a valid name"
        clear
        ./submenu.sh 2
        exit
    fi

    if [[ -f "databases/$currentDb/$tableName" || -f "databases/$currentDb/${tableName}_Schema" ]]; then
        echo "Table already exists."
        clear
        ./submenu.sh 2
        exit
    fi

    # Create Table and Schema
    touch "databases/$currentDb/$tableName"
    touch "databases/$currentDb/${tableName}_Schema"
    echo -n "$tableName," >> "databases/$currentDb/Schema"
    echo
    echo "Table '$tableName' successfully created."
    echo "Please specify its columns and their data types."
    echo "Valid datatypes: int, varchar, string!"
    insertCoulmn

    clear
    ./submenu.sh 2
    exit
}

typeset columnArray[2]

function insertCoulmn {
    echo
    echo -e "Number of columns: \c"
    read columnsNumber
    index=0

    if [[ $columnsNumber =~ ^[0-9]+$ ]]; then
        while (( index < columnsNumber )); do
            (( tracker = index + 1 ))
            echo
            echo -e "Enter Column $tracker: \c"
            read column
            echo -e "Enter DataType: \c"
            read dataType

            checkColumn "$column" "$dataType"
            if [ "$repeatFlag" -eq 1 ]; then
                echo "Duplicate column name '$column'"
            elif [ "$dataTypeIsExist" -eq 0 ]; then
                echo "Invalid datatype, please try again"
            else
                columnArray[$index]="$column"
                echo -n "$column,$dataType," >> "databases/$currentDb/${tableName}_Schema"
                echo -n "$column,$dataType," >> "databases/$currentDb/Schema"
                (( index++ ))
            fi
        done
    else 
        echo "Enter valid number"
        insertCoulmn
        return
    fi

    addPrimary
}

function checkColumn {
    repeatFlag=0
    for i in "${columnArray[@]}"; do
        if [ "$i" = "$1" ]; then
            repeatFlag=1
            break
        fi
    done
    source ./dataType.sh "check" "$2"
}

function addPrimary {
    echo -e "Choose one column to be your PK and enter its name: \c"
    read primaryKey
    isExistFlag=0
    for i in "${columnArray[@]}"; do
        if [ "$i" = "$primaryKey" ]; then
            isExistFlag=1
            break
        fi
    done

    if [ "$isExistFlag" -eq 0 ]; then
        echo "Invalid column"
        addPrimary
    else
        echo "$primaryKey" >> "databases/$currentDb/${tableName}_Schema"
        echo "$primaryKey" >> "databases/$currentDb/Schema"
        echo
        echo "Great, we are done here!"
        pause_back_to_submenu
    fi
}

createTable
