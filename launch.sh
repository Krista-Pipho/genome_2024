#!/bin/bash
#SBATCH --mem=150G
#SBATCH -c62
#SBATCH --partition=scavenger

pixi run snakemake --cores 60
#pixi run snakemake --rulegraph | dot -Tpng > rulegraph.png
#pixi run snakemake --report report.html
