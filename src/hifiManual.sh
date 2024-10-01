#!/bin/bash
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48
#SBATCH --partition scavenger

../bin/hifiasm -o $1.asm -t48 ../raw_data/m84165_231212_214911_s4.hifi_reads.$1.bam.fa 2> $1.asm.log

#../bin/hifiasm -o bc2009.asm -t48 ../raw_data/m84165_231212_214911_s4.hifi_reads.bc2009.bam.fa 2> bc2009.asm.log



