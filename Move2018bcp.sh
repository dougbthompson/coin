#!/bin/bash

# cp 2018bcp/mph.2018-01-01* 2018bcpx/01/01

# for M in `echo "12"`
for M in `echo "01 02 03 04 05 06 07 08 09 10 11"`
do

    for D in `echo "01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31"`
    do
        echo "Moving  Month: ${M} - Day: ${D}"
        cp 2018bcp/mph.2018-${M}-${D}* 2018bcpx/${M}/${D}
    done

done

