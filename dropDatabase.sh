DATABASE_DIR="databases"
read -rp "Enter database name to drop: " db
DB_PATH="$DATABASE_DIR/$db"

if [[ -d "$DB_PATH" ]]; then
    read -rp "Are you sure you want to drop '$db'? This cannot be undone (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf -- "$DB_PATH"
        echo "Database '$db' dropped successfully."
    else
        echo "Operation canceled."
    fi
else
    echo "Database '$db' does not exist."
fi

# pause function
pause() {
    read -rp $'\nif you want to continue press Enter ...' 
}

pause


