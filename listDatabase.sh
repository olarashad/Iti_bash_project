#!/bin/bash

DATABASE_DIR="./databases"
ERROR_LOG="./.error.log"

if [ ! -d "$DATABASE_DIR" ]; then
    echo "Database directory '$DATABASE_DIR' not found." >> "$ERROR_LOG"
    exit 1
fi

declare num=0
for db in $(ls "$DATABASE_DIR" 2>>"$ERROR_LOG"); do
    ((num++))
    echo "$num- $db" 
done
