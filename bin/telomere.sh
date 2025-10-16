#!/bin/bash


sample=$1
assembly=$2
clade=$3

bioawk -c fastx '{ if(length($seq) > 50000) { print ">"$name; print $seq }}' $assembly > analysis/${sample}/${sample}_filtered.fa # Filters out small contigs
tidk find --log -c $clade -o tidk_${sample} -d analysis/${sample} analysis/${sample}/${sample}_filtered.fa
tidk plot -t analysis/${sample}/tidk_${sample}_telomeric_repeat_windows.tsv -o analysis/${sample}/tidk_${sample}
cp analysis/${sample}/tidk_${sample}.svg results/${sample}
