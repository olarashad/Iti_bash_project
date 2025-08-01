#!/usr/bin/env bash

PS3="hosql-${currentDb}> "

function run_and_pause {
    clear
    "$@"
    echo
    read -rp "Press Enter to return to submenu..." _
    clear
}
echo "What would you like to do now?"
echo
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"
do
    case $REPLY in
        1)
            echo "Creating Table"
            run_and_pause ./create_table.sh
            ;;
        2)
            echo "Listing Tables"
            run_and_pause ./listTable.sh "list"
            ;;
        3)
            echo "Drop Table"
            run_and_pause ./dropTable.sh
            ;;
        4)
            echo "Insert into Table"
            run_and_pause ./Insert_into.sh
            ;;
        5)
            echo "Select From Table"
            run_and_pause ./select_from.sh
            ;;
        6)
            echo "Delete From Table"
            run_and_pause ./delete.sh
            ;;
        7)
            echo "Update Table"
            run_and_pause ./updateTable.sh
            ;;
        8)
            echo "Back To Main Menu"
            clear
            ./main.sh 1
            exit
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
