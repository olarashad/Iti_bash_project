#!/bin/bash

# pause helper
function pause_back_to_submenu {
    read -rp $'\nPress Enter to go back to the previous menu...' _
    clear
    ./submenu.sh 2
    exit
}

#Create Table
function createTable {
    echo -e "Enter Unique Table Name: \c"
    read tableName

    #Check if table exists
    if [ -z "$tableName" ]; then
        echo "You must enter a valid name"
        clear
        ./submenu.sh 2
        exit
    else 
        source ./listTable.sh "call" "$tableName"
    fi

    if [ "$tableExist" -eq 0 ]; then
        # create Table and schema files
        touch "databases/$currentDb/$tableName"
        touch "databases/$currentDb/${tableName}_Schema"
        echo -n "$tableName," >> "databases/$currentDb/Schema"
        echo
        echo "Table '$tableName' successfully created."
        echo
        echo "Please specify its columns and their data types."
        echo
        echo "Please note that the valid datatypes are: int, varchar, string!"
        echo -n ""
        insertCoulmn

        # بعد ما كل حاجة تتظبط، نرجع للـ submenu
        clear
        ./submenu.sh 2
        exit
    else
        echo "Table already exists."
        clear
        ./submenu.sh 2
        exit
    fi
}


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
            echo 
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

# Check Column
typeset columnArray[2]
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

# Add Primary Key
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
