#!/bin/bash

##Check table existance
function checkTableExistance
{
    echo -e "Enter table name: \c"
    read tbName
    if [ -z $tbName ]
    then
        echo "Error, empty input"
        echo "Back to table menu"
        ./submenu.sh 2
		exit
    fi
    tblIsExist=0
    for i in `cat databases/$currentDb/Schema | cut -f1 -d,`
    do
        if [ $i = $tbName ]
        then 
            ((tblIsExist=1))
            break;
        fi
    done

    if [ $tblIsExist -eq 0 ]
    then 
        echo "Error, table dose not exist"
        echo "Back to table menu"
        ./submenu.sh 2
		exit
    fi

    PS3="hosql-${tbName}>"
}
checkTableExistance

# Get Table Info
typeset fieldsArray[2]
function getTableInfo
{
    #calculate number of rows
    numberOfRows=`wc -l databases/$currentDb/${tbName} | cut -f1 -d' '`

    #to count no of fields in the table
    fieldLoopCounter=`awk -F, '{ print NF }' databases/$currentDb/${tbName}_Schema `

    #to know columns of this table
    ((fieldCounter=1))
    ((arrayCounter=0))
    for ((j=0;j<"$fieldLoopCounter-1";j++));do
        i=`cat databases/$currentDb/${tbName}_Schema | cut -f$fieldCounter -d,`
        if [ $i != "int" -a $i != "varchar" -a $i != "string" ]
        then
            fieldsArray[$arrayCounter]=$i
            ((arrayCounter=arrayCounter+1))
        fi
        ((fieldCounter=fieldCounter+1))
    done
}
getTableInfo

# Select Rows
function selectRows
{
    select choice in "Select all" "Select Row" "Exit"
    do
        case $choice in
            "Select all")
                    ((firstRowFlag=0))
                    displayData 0 
                ;;
            "Select Row")
                    echo -e "Insert column name: \c"
                    read clmnName
                    if [ -z $clmnName ]
                    then
                        echo "Error, empty input"
                    else
                            ((firstRowFlag=0))
                            checkClmn $clmnName
                    fi
                ;;
            "Exit")
                    echo "Back to table menu"
                    ./submenu.sh 2
		            exit
                ;;
            *)
                    echo "Invalid choice"
                ;;
        esac
    done
}

# Display all data
typeset -i firstRowFlag
((firstRowFlag=0))
function displayData
{
    if [ $firstRowFlag -eq 0 ]
    then
        ((firstRowFlag=1))
        echo "----------------------------------------------------------"
        echo -e "|\c"
        for ((j=0;j<"$arrayCounter-1";j++));do
            echo -e "${fieldsArray[j]}          |\c"
        done
        echo "${fieldsArray[j]}          "
        echo "----------------------------------------------------------"
    fi
    if [ $1 -eq 0 ] 
    then
        typeset dataArray[1]
        typeset dataArrayCounter=0
        typeset linesCounter=0
        for ((i=0;i<"$numberOfRows";i++));do
            ((dataArrayCounter=0))
            for ((j=2;j<"$fieldLoopCounter";j=j+2));do
                ((linesCounter=i+1))
                element=`head -$linesCounter databases/$currentDb/${tbName} | tail -1 | cut -f$j -d,`
                dataArray[$dataArrayCounter]=$element
                ((dataArrayCounter=dataArrayCounter+1))
            done
            echo -e "|\c"
            for ((k=0;k<"$dataArrayCounter-1";k++));do  
                echo -e "${dataArray[k]}          |\c" 
            done
            echo "${dataArray[k]}          "
            echo "----------------------------------------------------------"
        done
        return
    elif [ $1 -eq 1 ]
    then
        ((dataArrayCounter=0))
        for ((j=2;j<"$fieldLoopCounter";j=j+2));do
            ((linesCounter=i+1))
            element=`head -$linesCounter databases/$currentDb/${tbName} | tail -1 | cut -f$j -d,`
            dataArray[$dataArrayCounter]=$element
            ((dataArrayCounter=dataArrayCounter+1))
        done
        echo -e "|\c"
        for ((k=0;k<"$dataArrayCounter-1";k++));do  
            echo -e "${dataArray[k]}          |\c" 
        done
        echo "${dataArray[k]}          "
        echo "----------------------------------------------------------"
    fi
}

# Check column
typeset clmnIsExist
typeset clmnID #this will be used to exclusively serch the fields of the entered 
               #clmn for the entred value by the user
function checkClmn
{
    ((clmnIsExist=0))
    ((clmnID=0))
    for ((i=0;i<"$fieldLoopCounter";i++));do
        ((clmnID=clmnID+2))
        if [[ $1 = ${fieldsArray[i]} ]]
        then
            ((clmnIsExist=1))
            break
        fi
    done
    if [ $clmnIsExist -eq 0 ]
    then 
        echo "Error, column dose not exist"
        return
    fi
    echo -e "Insert value: \c"
    read clmnValue
    searchValue $clmnID $clmnValue
}

# Search for special values
function searchValue
{
    typeset dataExistFlag
    ((dataExistFlag=0))
    for ((i=0;i<"$numberOfRows";i++));do
        ((linesCounter=i+1))
        element=`head -$linesCounter databases/$currentDb/${tbName} | tail -1 | cut -f$1 -d,`
        if [[ $element = $2 ]]
        then
            ((dataExistFlag=1))
            displayData 1 $linesCounter 
        fi
    done
    if [ $dataExistFlag -eq 0 ]
    then
        echo "Error, Data dose not exist"
        return
    fi
}


selectRows