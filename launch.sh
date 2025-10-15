#!/bin/bash
#SBATCH --mem=150G
#SBATCH -c32
#SBATCH --partition=scavenger

#singularity exec docker://staphb/kraken2 kraken2 build --db k2_standard_08_GB_20250714 --threads 30
#singularity exec docker://staphb/kraken2 kraken2-build --standard --threads 34 --db k2_8 --max-db-size 8000000000
#singularity exec docker://nanozoo/kraken2:2.1.1--d5ded30 kraken2-build --standard --threads 30 --db k2_alt
#singularity exec docker://staphb/kraken2 kraken2 classify --db k2_standard_08_GB_20250714 --threads 30 --unclassified-out unclassified_SRR --classified-out classified_SRR SRR13577847.fa	
pixi run snakemake --cores 30
#pixi run snakemake --rulegraph | dot -Tpng > rulegraph.png
#pixi run snakemake --cores 1
#pixi run snakemake --report report.html
