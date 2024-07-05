#!/bin/bash
module load Java/1.8.0_60
module load samtools/1.9

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

    samplePoints=$scaffoldLen/100
    path="../results/readAlign/"
    sampleData=("${path}S1.dedup.bam" "${path}S2.dedup.bam" "${path}S3.dedup.bam" "${path}S4.dedup.bam") #array
    samples=(S1 S2 S3 S4)
 
    #makefileNames
    for i in {0..3}
    do
        plotCoverage -b ${sampleData[i]} $scaffoldName -o "./scaffoldCov/${samples[i]}.coverage_plot.png" --outRawCounts "./scaffoldCov/${samples[i]}.$scaffoldName.txt"
    done
    
    for j in {0..3}
    do
        touch sampleCov >> {sample} $scaffoldName $meanCov >> append to file
    done
done