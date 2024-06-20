#!/bin/bash
#SBATCH --mem=24G
#SBATCH --cpus-per-task=10
#SBATCH --partition scavenger
/work/alh166/genome_2024/bin/jellyfish-2.3.1/bin/jellyfish count -C -m 20 -s 1000000000 -t 10 /work/alh166/genome_2024/raw_data/m84165_231212_214911_s4.hifi_reads.bc2010.bam.fa -o /work/alh166/genome_2024/analysis/bc2010.jf 
/work/alh166/genome_2024/bin/jellyfish-2.3.1/bin/jellyfish histo -t 10 /work/alh166/genome_2024/analysis/bc2010.jf > /work/alh166/genome_2024/analysis/bc2010.histo
#var ourpur or ../Lvar.....
#output is  /PATH/PATH/Lvar_scaffolds.jf and /PATH/Lvar_scaffolds.histo
/work/alh166/genome_2024/bin/genomescope2.0/genomescope.R -i /work/alh166/genome_2024/analysis/bc2010.histo -o /work/alh166/genome_2024/results -k 20
