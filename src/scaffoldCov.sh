#!/bin/bash

#make loop start at 1 bc unitig num start at 1 (bash starts at 1)
#$1 $2 are samples

set -x
trap read debug

#scaffoldAmt=$(wc -l ../results/readAlign/bc2010.asm.p_utg.fa.fai | awk '{print $1}')
#${scaffoldArr:0:10} gets first 10 chars

readarray -t scaffoldArr < ../results/readAlign/bc2010.asm.p_utg.fa.fai 


for scaffold in "${scaffoldArr[@]}"
do
    #cut is -d delimiter of space, -f 1 is field 1
    scaffoldName=$(echo $scaffold | cut -d ' ' -f 1)
    scaffoldLen=$(echo $scaffold | cut -d ' ' -f 2)

    samples=$scaffoldLen/100
    samples=(S1 S2 S3 S4) #array
 
    #makefileNames
    fileNames="___ --- ---- ---  {sample}.$i"
    meanCov=plotCoverage -b $1 $2 -o coverage_plot.png --outRawCounts $fileNames> get mean
    #region = scaffold
    for j in {1...4}
    do
        touch sampleCov >> {sample} $scaffoldName $meanCov >> append to file
    done
done