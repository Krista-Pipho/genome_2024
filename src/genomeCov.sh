#!/bin/bash
#SBATCH --mem=50G
#SBATCH --cpus-per-task=24
#SBATCH --partition scavenger

plotCoverage -b ../results/2011_align/S1.dedup.bam ../results/2011_align/S2.dedup.bam ../results/2011_align/S3.dedup.bam ../results/2011_align/S4.dedup.bam --plotFile ../results/2011_align/2011_genome_coverage --outRawCounts ../results/2011_align/2011_genome_cov.tab
