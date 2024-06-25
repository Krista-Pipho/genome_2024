#!/bin/bash

declare -A snakemake_input=( [0]="../raw_data/m84165_231212_214911_s4.hifi_reads.bc2011.bam.fa" )
declare -A snakemake_output=( [0]="../results/m84165_231212_214911_s4.hifi_reads.bc2011.bam.fa.linear_plot.png" )
declare -A snakemake_params=( )
declare -A snakemake_wildcards=( [0]="m84165_231212_214911_s4.hifi_reads.bc2011.bam.fa" [sample]="m84165_231212_214911_s4.hifi_reads.bc2011.bam.fa" )
declare -A snakemake_resources=( [0]="1" [_cores]="1" [1]="1" [_nodes]="1" [2]="/tmp" [tmpdir]="/tmp" )
declare -A snakemake_log=( )
declare -A snakemake_config=( )
declare -A snakemake=( [threads]="1" [rule]="fasta_qc" [bench_iteration]="None" [scriptdir]="/work/alh166/genome_2024/src" )
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
kmer=20
../bin/jellyfish count -C -m $kmer -s 1000000000 -t 10 ../raw_data/"${snakemake_wildcards[sample]}" -o ../analysis/"${snakemake_wildcards[sample]}".jf
../bin/jellyfish histo -t 10 ../analysis/"${snakemake_wildcards[sample]}".jf > ../analysis/"${snakemake_wildcards[sample]}".histo
#var ourpur or ../Lvar.....
#output is  /PATH/PATH/Lvar_scaffolds.jf and /PATH/Lvar_scaffolds.histo
../bin/genomescope2.0/genomescope.R -i ../analysis/${snakemake_wildcards[sample]}.histo -o ../results -k $kmer

#Failed to open input file '../analysis/m84165_231212_214911_s4.hifi_reads.bc2011.bam.jf'
