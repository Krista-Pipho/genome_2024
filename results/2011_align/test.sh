#!/bin/bash

averages=""

while read sample mean std min p25 p50 p75 max; do
    averages="${averages} ${mean}"
done < ptg000001l_coverageStats.txt



averages=$(echo "$averages" | awk '{print $2 " " $3 " " $4 " " $5}')
echo $averages
scaffoldName=adf
touch /../results/scaffoldCov.txt | echo $scaffoldName $averages | tr ' ' '\t' >> /../results/scaffoldCov.txt

