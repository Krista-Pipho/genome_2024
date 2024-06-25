#!/bin/bash
set -x
#SBATCH --mem=24G
#SBATCH --cpus-per-task=10
#SBATCH --partition scavenger
#args: kmer length, path prefix to input data
#*** see if can make the jellyfish path relative and make computer look recursively for the program even if in parent folder
#/bin/jellyfish count -C -m $1 -s 1000000000 -t 10 ../raw_data/$2 -o ../analysis/$3.jf 
#../bin/jellyfish histo -t 10 ../analysis/$3.jf > ../analysis/$3.histo
#var ourpur or ../Lvar.....
#output is  /PATH/PATH/Lvar_scaffolds.jf and /PATH/Lvar_scaffolds.histo
#../bin/genomescope2.0/genomescope.R -i ../analysis/$3.histo -o ../results -k $1

#/*/genome_2024/*/jellyfish count -C -m $1 -s 1000000000 -t 10 /work/alh166/genome_2024/raw_data/m84165_231212_214911_s4.hifi_reads.bc2010.bam.fa -o /work/alh166/genome_2024/analysis/bc2010.jf 

echo Enter desired k-mer size:
read kmer
../bin/jellyfish count -C -m $kmer -s 1000000000 -t 10 ../raw_data/{wildcards.sample} -o ../analysis/{wildcards.sample}.jf 
../bin/jellyfish histo -t 10 ../analysis/{wildcards.sample}.jf > ../analysis/{wildcards.sample}.histo
#var ourpur or ../Lvar.....
#output is  /PATH/PATH/Lvar_scaffolds.jf and /PATH/Lvar_scaffolds.histo
../bin/genomescope2.0/genomescope.R -i ../analysis/{wildcards.sample}.histo -o ../results -k $kmer
