#!/bin/bash
#SBATCH --mem=400G
#SBATCH -c62
#SBATCH --time=04-00:00:00

#pixi run samtools fastq sample.bam > sample.fastq
pixi run snakemake --cores 60 -k
#pixi run snakemake --rulegraph | dot -Tpng > rulegraph.png
pixi run snakemake --report report.html

