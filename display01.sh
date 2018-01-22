#!/bin/bash

while true
do
    clear; echo ""; date; echo "";  
    mysql coins -e "call report02(24);"; echo ""; 
    sleep 300; 
done

