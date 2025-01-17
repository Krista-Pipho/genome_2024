#!/bin/bash


sample=$1
assembly=$2

bioawk -c fastx '{ if(length($seq) > 50000) { print ">"$name; print $seq }}' ${assembly} > ${sample}_filtered.fa # Filters out small contigs
tidk find --log -c Lepidoptera -o tidk_${sample} -d tidk_${sample} ${sample}_filtered.fa
tidk plot -t tidk_${sample}/tidk_${sample}_telomeric_repeat_windows.tsv -o tidk_${sample}
