#!/bin/bash

#Create Table
function createTable
{
        echo -e "Enter Unique Table Name: \c"
        read tableName

        #Check if table exists
        if [ -z $tableName ]
        then
                echo "You Must Enter Valid Name"
                ./submenu.sh 2
                exit
        else 
                source ./listTable.sh "call" $tableName
        fi

        if [ $tableExist -eq 0 ]
        then
                #create Table directory and Schema
                touch databases/$currentDb/$tableName 
                touch databases/$currentDb/${tableName}_Schema 
                echo -e "$tableName,\c" >> databases/$currentDb/Schema

                echo -e "Table $tableName Successfully Created"
                insertCoulmn
                ./submenu.sh 2
                exit
        else
                echo "Table Already Exsits"
                ./submenu.sh 2
                exit
        fi
}

# Insert Column
function insertCoulmn
{
	echo -e "Number of columns:\c"
	read columnsNumber
	index=0
        if [[ $columnsNumber == +([0-9]) ]]
        then
            while ((index<columnsNumber))
	    do
                (( tracker=index + 1 ))
		echo -e "Enter Column $tracker:\c"
		read column
		echo -e "Enter DataType:\c"
		read dataType
                checkColumn $column $dataType
                if [ $repeatFlag -eq 1 ]
                then
                        echo "Duplicate column name $column"
		elif [ $dataTypeIsExist -eq 0 ]
                then
                        echo "Datatype dose not exist"
                else
                       columnArray[$index]=$column
                       echo -e "$column,$dataType,\c" >> databases/$currentDb/${tableName}_Schema
                       echo -e "$column,$dataType,\c" >> databases/$currentDb/Schema
                       (( index+=1 ))
                fi
             done
        else 
                echo "Enter Valid Number"
                insertCoulmn
        fi
	

       addPrimary 
        
}

# Check Column
typeset columnArray[2]
function checkColumn
{
        repeatFlag=0
        for i in ${columnArray[@]}
        do
                if [ $i = $1 ]
                then
                        repeatFlag=1
                        break
                fi
        done
        source ./dataType.sh "check" $2
}

# Add Primary Key
function addPrimary
{
        echo -e "Enter Primary Key:\c"
        read primaryKey
        isExistFlag=0
        for i in ${columnArray[@]}
        do
                if [ $i = $primaryKey ]
                then
                        (( isExistFlag=1 ))
                        break
                fi
        done
        if [ $isExistFlag -eq 0 ]
        then
                echo "Invalid column"
                addPrimary
        else
                echo -e "$primaryKey" >> databases/$currentDb/${tableName}_Schema
                echo -e "$primaryKey" >> databases/$currentDb/Schema        
        fi
}

createTable



