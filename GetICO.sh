#!/bin/bash

# select timestamp('2018-01-31 00:00');       == 2018-01-31 00:00:00
# select unix_timestamp('2018-01-31 00:00');  == 1517385600

if [ "$1" == "" ]; then
    for FILE in `find . -name "*.html" -print `
    do
        export DT0=`echo ${FILE} | cut -c18-33`
        export DT1=`echo ${DT0}  | cut -c 1-10`
        export DT2=`echo ${DT0}  | cut -c12-13`
        export DT3=`echo ${DT0}  | cut -c15-16`
        export DT="${DT1} ${DT2}:${DT3}"
    
        # echo "${FILE} | ${DT0} | ${DT1} | ${DT2} | ${DT3} | <${DT}>"
        export TS=`mysql mysql --skip-column-names -e"select unix_timestamp('${DT}');"`
        echo "${FILE} + ${DT} + ${TS}"

        cat ${FILE} | tr '\241' '~' | tr '\320' '~' | tr '\251' '~' | tr '\360' '~' | tr '\237' '~' | tr '\217' '~' | tr '\223' '~' | tr '\200' '~' | tr '\342' '~' | tr '\231' '~' | tr '\224' '~' | tr '\302' '~' | sed -e"s/~//g" > /tmp/z.html

        python parse.py /tmp/z.html "${DT}" "${TS}"
    done
else
    export FILE=$1
    export DT0=`echo ${FILE} | cut -c18-33`
    export DT1=`echo ${DT0}  | cut -c 1-10`
    export DT2=`echo ${DT0}  | cut -c12-13`
    export DT3=`echo ${DT0}  | cut -c15-16`
    export DT="${DT1} ${DT2}:${DT3}"
    export TS=`mysql mysql --skip-column-names -e"select unix_timestamp('${DT}');"`
    echo "${FILE} + ${DT} + ${TS}"

    cat ${FILE} | tr '\241' '~' | tr '\320' '~' | tr '\251' '~' | tr '\360' '~' | tr '\237' '~' | tr '\217' '~' | tr '\223' '~' | tr '\200' '~' | tr '\342' '~' | tr '\231' '~' | tr '\224' '~' | tr '\302' '~' | sed -e"s/~//g" > /tmp/z.html

    python parse.py /tmp/z.html "${DT}" "${TS}"
fi

exit

