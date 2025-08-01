#!/bin/bash

# pause helper
function pause {
    read -rp $'\nPress Enter to continue...' _
    clear
    ./submenu.sh 2
    exit
}

# List all tables
echo "the existing tables in the database '$currentDb' are:"
echo

if [ "$1" == "list" ]; then
    num=0
    for table in databases/$currentDb/*; do
        filename=$(basename "$table")
        [[ "$filename" == *Schema* ]] && continue
        ((num++))
        echo "$num- $filename"
    done
    pause
fi

# Check if a specific table exists
if [ "$1" == "call" ]; then
    tableExist=0
    if [ -f "databases/$currentDb/$2" ]; then
        tableExist=1
    fi
fi
