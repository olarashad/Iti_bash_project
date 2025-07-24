
DATABASE_DIR="databases"
read -rp "Enter database name to drop: " db
DB_PATH="$DATABASE_DIR/$db"

  if [[ -d "$DB_PATH" ]]; then
    read -rp "Are you sure you want to drop '$DB_PATH'? This cannot be undone (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
      rm -rf "$DB_PATH"
      echo "Database '$DB_PATH' dropped."
    else
      echo "Operation canceled."
    fi
  else
    echo "Database '$DB_PATH' does not exist."
  fi
  