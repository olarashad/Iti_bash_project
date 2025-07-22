
function connect_to_db {
    dbName="$1"
    dbPath="databases/$dbName"

    while true; do
        # لو الاسم مش متبعت أو مفيش فولدر بالاسم جوه databases
        if [ -z "$dbName" ] || [ ! -d "$dbPath" ]; then
            echo "❌ Database '$dbName' does not exist."

            echo ""
            echo "What would you like to do?"
            echo "1) Try again"
            echo "2) Return to main menu"
            echo ""

            read -rp "Choose an option [1-2]: " choice
            case $choice in
                1)
                    read -rp "Enter database name to connect: " dbName
                    dbPath="databases/$dbName"
                    ;;
                2)
                    echo "🔙 Returning to main menu..."
                    sleep 1
                    exit 0
                    ;;
                *)
                    echo "❌ Invalid choice. Returning to main menu."
                    sleep 1
                    exit 1
                    ;;
            esac
        else 
            export currentDb="$dbName"
            echo "✅ Connected to database '$currentDb'."
            ./submenu.sh
            break
        fi
    done
}

connect_to_db "$1"
