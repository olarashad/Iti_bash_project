#!/bin/bash

# Prompt for table name
read -p "Enter Table Name: " tbName

# Validate input
if [ -z "$tbName" ]; then
    echo "❌ You must enter a valid table name."
    ./submenu.sh 
    exit 1
fi

# Check if table file exists
tableFile="databases/$currentDb/$tbName"
schemaFile="databases/$currentDb/${tbName}_Schema"
schemaList="databases/$currentDb/Schema"

if [ ! -f "$tableFile" ]; then
    echo "❌ Table '$tbName' does not exist."
    ./submenu.sh
    exit 1
fi

# Delete table and related files
rm -f "$tableFile" "$schemaFile" 2>>./.error.log
sed -i "/^$tbName,/d" "$schemaList"

echo "✅ Table '$tbName' deleted successfully."
./submenu.sh
exit 0