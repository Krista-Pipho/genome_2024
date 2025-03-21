#!/bin/bash 
#SBATCH --mem=30G
#SBATCH --cpus-per-task=5
#SBATCH --partition scavenger
#args: kmer length, path prefix to input data
#*** see if can make the jellyfish path relative and make computer look recursively for the program even if in parent folder
#/bin/jellyfish count -C -m $1 -s 1000000000 -t 10 ../raw_data/$2 -o ../analysis/$3.jf 
#../bin/jellyfish histo -t 10 ../analysis/$3.jf > ../analysis/$3.histo
#var ourpur or ../Lvar.....
#output is  /PATH/PATH/Lvar_scaffolds.jf and /PATH/Lvar_scaffolds.histo
#../bin/genomescope2.0/genomescope.R -i ../analysis/$3.histo -o ../results -k $1

#/*/genome_2024/*/jellyfish count -C -m $1 -s 1000000000 -t 10 /work/alh166/genome_2024/raw_data/m84165_231212_214911_s4.hifi_reads.bc2010.bam.fa -o /work/alh166/genome_2024/analysis/bc2010.jf 

#desired kmer size

kmer=20

output_name=$1
raw_data=$2

../bin/jellyfish count -C -m $kmer -s 1000000000 -t 10 ${raw_data} -o ../analysis/${output_name}.jf
../bin/jellyfish histo -t 10 ../analysis/${output_name}.jf > ../analysis/${output_name}.histo

module load R/4.4.0
conda install r-minpack.lm
conda install r-argparse
#R> install.packages("minpack.lm")
#conda install minpack.lm

#find docker for genome scope, or figure out why slurm errors on minpack.lm not exisitng

../bin/genomescope2.0/genomescope.R -i ../analysis/${output_name}.histo -o ../results -k $kmer

#sbatch kmerAnalysis.sh bc2011 ../raw_data/reads/m84165_231212_214911_s4.hifi_reads.bc2011.bam.fa