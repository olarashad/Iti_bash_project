#!/usr/bin/env bash

#!/bin/bash

PS3="hosql-${currentDb}>"

# Display Table Actions
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Table Meta Data" "Exit"
do
    case $REPLY in
        1) 
            echo "Creating Table"
            ./create_table.sh
        ;;
        2)
            echo "Listing Tables"
            ./listTables.sh "list"
        ;;
        3)
            echo "Drop Table"
            ./dropTable.sh
        ;; 
        4)
            echo "Insert into Table"
            ./insertRow.sh
        ;;
	    5)
            echo "Select From Table"
            ./selectRow.sh
        ;;
	    6)
            echo "Delete From Table"
            ./deleteRow.sh
        ;;
	    7)
            echo "Update Table"
            ./updateTable.sh
        ;;
        # 8)
        #     echo "Table Meta Data"
	    #     ./metaData.sh
        # ;;
        8)
            echo "Back To Main Menu"
            ./create_database.sh 1
            exit
        ;;
        *) echo "invaled option"
        ;;
    esac
done