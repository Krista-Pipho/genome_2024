#!/bin/bash


sample=$1
reads=$2

hifiasm -t32 -o analysis/${sample}/$sample $reads 2> analysis/${sample}/${sample}.log
awk '/^S/{print ">"$2;print $3}' analysis/${sample}/${sample}.bp.p_ctg.gfa > analysis/${sample}/${sample}.p_ctg.fa  # get primary contigs in FASTA
cp analysis/${sample}/${sample}.p_ctg.fa ${sample}.gfa
