#!/bin/bash

read -p "Enter Table Name: " tbName

# Validate input
if [ -z "$tbName" ]; then
    echo "You must enter a valid table name."
    ./submenu.sh 
    exit 1
fi

# Check if table file exists
tableFile="databases/$currentDb/$tbName"
schemaFile="databases/$currentDb/${tbName}_Schema"
schemaList="databases/$currentDb/Schema"

if [ ! -f "$tableFile" ]; then
    echo "Table '$tbName' does not exist."
    ./submenu.sh
    exit 1
fi

# Delete table and related files
rm -f "$tableFile" "$schemaFile" 
sed -i "/^$tbName,/d" "$schemaList"
echo
echo "Table '$tbName' deleted successfully."
echo
echo "back to the table menu..."
sleep 3
clear
./submenu.sh
exit 0