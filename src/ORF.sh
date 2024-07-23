#!/bin/bash
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10
#SBATCH --partition scavenger

#https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/USAGE.txt
ORFfinder -in ../results/2011_align/W_bc2011.masked.fasta -s 0 -out ../results/2011_align/W.masked.ORF -outfmt 1 -logfile ../results/2011_align/W.masked.ORF