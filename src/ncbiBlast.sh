#!/bin/bash
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10
#SBATCH --partition scavenger

module load Python/2.7.11
module load NCBI-BLAST/2.12.0-rhel8

#Create a custom database from a multi-FASTA file of sequences with this minimal command:

#makeblastdb -in ../results/2011_align/W_H.charithonia.fasta -parse_seqids -title "charithonia" -dbtype nucl
#makeblastdb -in ../results/2011_align/W_H.congener.fasta -parse_seqids -title "congener" -dbtype nucl


#blasting masked genome ORFs against the reference dbs created above - has matches!!! 
blastn -db ../results/2011_align/W_H.charithonia.fasta -query ../results/2011_align/W.masked.ORF -out ../results/2011_align/W_2011.charithonia.out
blastn -db ../results/2011_align/W_H.congener.fasta -query ../results/2011_align/W.masked.ORF -out ../results/2011_align/W_2011.congener.out

#trying another scaffold to ensure im not dumb 
#blastn -db ../results/2011_align/W_H.charithonia.fasta -query ../results/2011_align/scaf10.masked.ORF -out ../results/2011_align/scaf10_2011.charithonia.out
