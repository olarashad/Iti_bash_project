
DB_PATH=""


function pause() {
  read -rp "If you want to continue press Enter ..."
}


function create_database() {
  read -rp "Enter database name: " db
  if [[ -z "$db" ]]; then
    echo "Name cannot be empty."
  elif [[ -d "databases/$db" ]]; then
    echo "Database '$db' already exists."
  else
    while true; do
      read -rsp "please enter password for database '$db': " password
      echo
      read -rsp "Confirm password: " confirm
      echo
      if [[ "$password" == "$confirm" && -n "$password" ]]; then
        break
      else
        echo "Passwords do not match or  empty. please try again."
      fi
    done
   mkdir -p "databases/$db"
    echo -n "$password" > "databases/$db/.dbpass"
    chmod 600 "databases/$db/.dbpass"

    echo "Database '$db' created and secured with a password."
  fi
  pause
}
  
function list_databases() {
  
  echo "Available databases:"
  shopt -s nullglob
local dbs=(databases/*/)
  shopt -u nullglob
  if [[ ${#dbs[@]} -eq 0 ]]; then
    echo "There are no databases."
  else
    for d in "${dbs[@]}"; do
      echo "${d%/}"
    done
  fi
  pause
}



function drop_database() {
  ./dropDatabase.sh 
}


function connect_database() {
  read -rp "please enter database name to connect: " db
  ./connect_db.sh "$db"
}



function main_menu() {
  while true; do
    clear
    echo "=== Bash DBMS ==="
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect to Database"
    echo "4) Drop Database"
    echo "5) Exit"
    read -rp "Select an option [1-5]: " opt
    case $opt in
      1) create_database;;
      2) list_databases;;
      3) connect_database;;
      4) drop_database;;
      5) echo "Goodbye, see you soon!!"; exit 0;;
      *) echo "Invalid option."; pause;;
    esac
  done
}


enable_paging() {
  shopt -s extglob
}



enable_paging
main_menu