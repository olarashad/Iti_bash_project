function connect_to_db {
    dbName="$1"
    dbPath="databases/$dbName"
    passFile="$dbPath/.dbpass"

    while true; do
        if [ -z "$dbName" ] || [ ! -d "$dbPath" ]; then
            clear
            echo "Database '$dbName' does not exist."
            echo
            echo "What would you like to do?"
            echo "1) Try again"
            echo "2) Return to main menu"
            echo

            read -rp "Choose an option [1-2]: " choice
            case $choice in
                1)
                    read -rp "Enter database name to connect: " dbName
                    dbPath="databases/$dbName"
                    passFile="$dbPath/.dbpass"
                    ;;
                2)
                    echo "Returning to main menu..."
                    sleep 1
                    exit 0
                    ;;
                *)
                    echo "Invalid choice. Returning to main menu."
                    sleep 1
                    exit 1
                    ;;
            esac

        elif [ ! -f "$passFile" ]; then
            clear
            echo "No password file found for '$dbName'. Cannot connect."
            sleep 1
            exit 1

        else
            read -rsp "Enter password for '$dbName': " inputPass
            echo

            storedPass=$(<"$passFile")

            if [[ "$inputPass" == "$storedPass" ]]; then
                export currentDb="$dbName"
                clear
                echo "Connected to database '$currentDb'."
                echo
                echo "You can now perform operations on '$currentDb' database..."
                echo

                # يفتح الـ submenu في صفحة نظيفة
                ./submenu.sh
                echo
                break
            else
                clear
                echo "Incorrect password."
                echo
                echo "What would you like to do?"
                echo "1) Try again"
                echo "2) Return to main menu"
                echo

                read -rp "Choose an option [1-2]: " passChoice
                case $passChoice in
                    1) continue ;;
                    2) echo "Returning to main menu..."; exit 0 ;;
                    *) echo "Invalid choice. Exiting."; exit 1 ;;
                esac
            fi
        fi
    done
}

connect_to_db "$1"
