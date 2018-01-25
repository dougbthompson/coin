#!/bin/bash

while true
do
    clear; echo ""; date; echo "";  
    echo -ne "\e[1;32;44m "
    mysql coins -e "call report02(24);"; echo ""; 
    echo -ne "\e[m \n"
    sleep 300; 
done

