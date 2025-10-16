#!/bin/bash


sample=$1
reads=$2
cores=$3

hifiasm -t${cores} -o analysis/${sample}/$sample $reads 2> analysis/${sample}/${sample}.log
awk '/^S/{print ">"$2;print $3}' analysis/${sample}/${sample}.bp.p_ctg.gfa > analysis/${sample}/${sample}.gfa  # get primary contigs in FASTA
cp analysis/${sample}/${sample}.gfa ${sample}.gfa
