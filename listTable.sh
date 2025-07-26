#!/bin/bash

# List all tables
if [ "$1" == "list" ]; then
    num=0
    for table in databases/$currentDb/*; do
        filename=$(basename "$table")
        [[ "$filename" == *Schema* ]] && continue
        ((num++))
        echo "$num- $filename"
    done
    ./submenu.sh
    exit
fi

# Check if a specific table exists
if [ "$1" == "call" ]; then
    tableExist=0
    if [ -f "databases/$currentDb/$2" ]; then
        tableExist=1
    fi
fi