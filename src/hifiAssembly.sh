#!/bin/bash
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48
#SBATCH --partition scavenger
#{wildcards.name}


../bin/hifiasm -o ../analysis/$prefix -t48 ../raw_data/{wildcards.sample} 2> $prefix.log
#intput of reads into output .asm assembly file 
#../bin/hifiasm -o bc2010.asm -t48 /work/alh166/genome_2024/raw_data/m84165_231212_214911_s4.hifi_reads.bc2010.bam.fa 2> bc2010.asm.log
mv $prefix.bp.p_utg.gfa ../results


