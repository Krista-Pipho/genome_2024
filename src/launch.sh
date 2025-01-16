#!/bin/bash
#SBATCH --mem=50G
#SBATCH -c16
#SBATCH --partition=scavenger

snakemake --rulegraph | dot -Tpng > rulegraph.png
snakemake
snakemake --report report.html
