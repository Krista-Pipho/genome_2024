#!/bin/bash


sample=$1
reads=$2

hifiasm -t32 -o $sample $reads 2> ${sample}.log
awk '/^S/{print ">"$2;print $3}' ${sample}.bp.p_ctg.gfa > ${sample}.p_ctg.fa  # get primary contigs in FASTA
