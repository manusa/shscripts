#!/bin/sh
############################################################################################################################################
#  Script     : jtlsummarize.sh
#  Author     : Marc Nuri
#  Date       : 2018/01/10
#  Last Edited: 2018/01/10, Marc Nuri
#  Description: Script to build a text summary from a JMeter jtl results file
############################################################################################################################################

USAGE="Usage: jtlsummarize.sh <filename> \nSummarizes JMeter JTL output"
[ $1 ] || { echo $USAGE; exit 1 ; }

INPUT_FILE=$1
echo "Processing $INPUT_FILE\c"

ls $INPUT_FILE || { echo "File not found <$INPUT_FILE>"; exit 1 ; }


WORK_FILE=$INPUT_FILE.temp
OUTPUT_FILE=$INPUT_FILE.summary

# Clear output file
echo 'JMeter execution summary' > $OUTPUT_FILE
printf "================================================================================\n">> $OUTPUT_FILE

#Remove first line (Col titles) > sed -n '2,$ p' $INPUT_FILE |\
TOTAL_COUNT=$(sed -n '2,$ p' $INPUT_FILE | cut -c -10,14- | sort | awk -F',' '{count++} END {print count}')
ERROR_COUNT=$(sed -n '2,$ p' $INPUT_FILE | cut -c -10,14- | sort | awk -F',' '$8  == "false" {count++} END {print count}')

printf "Total Samples: $TOTAL_COUNT\nErrors: $ERROR_COUNT\n" >> $OUTPUT_FILE

if [ $ERROR_COUNT -ne 0 ]; then
    printf "================================================================================\n">> $OUTPUT_FILE
    printf "Threads with error:\n\n">> $OUTPUT_FILE
    printf "COUNT Thread\n">> $OUTPUT_FILE
    printf "===== ======\n">> $OUTPUT_FILE
    cat $INPUT_FILE | awk -F, 'NR>1 && $8 == "false"{arr[$6]++}END{for (a in arr) printf "%-5s %s\n", arr[a], a}' >> $OUTPUT_FILE
    printf "\n\n">> $OUTPUT_FILE

    printf "Failed samples:\n\n">> $OUTPUT_FILE
    cat $INPUT_FILE | awk -F, 'NR>1 && $8 == "false"{printf "%s (%s)\n", $3, $6}' >> $OUTPUT_FILE
fi