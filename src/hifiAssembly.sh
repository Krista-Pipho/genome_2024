#!/bin/bash
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48
#SBATCH --partition scavenger

output_name=$1
raw_data=$2
../bin/hifiasm -o ../analysis/${output_name} -t48 ${raw_data} 2> ../logs/${output_name}.log#intput of reads into output .asm assembly file 
#../bin/hifiasm -o bc2010.asm -t48 /work/alh166/genome_2024/raw_data/m84165_231212_214911_s4.hifi_reads.bc2010.bam.fa 2> bc2010.asm.log
#../bin/hifiasm -o bc2009.asm -t48 ../raw_data/m84165_231212_214911_s4.hifi_reads.bc2009.bam.fa 2> bc2009.asm.log

#mv "${snakemake_wildcards[sample]}".bp.p_utg.gfa ../results
wait




