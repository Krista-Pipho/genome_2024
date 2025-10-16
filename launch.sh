#!/bin/bash
#SBATCH --mem=150G
#SBATCH -c32
#SBATCH --partition=scavenger

pixi run snakemake --cores 30
#pixi run snakemake --rulegraph | dot -Tpng > rulegraph.png
#pixi run snakemake --report report.html
