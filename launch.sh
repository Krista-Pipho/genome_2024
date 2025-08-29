#!/bin/bash
#SBATCH --mem=50G
#SBATCH -c32
#SBATCH --partition=scavenger

pixi run snakemake --rulegraph | dot -Tpng > rulegraph.png
pixi run snakemake --cores 1
pixi run snakemake --report report.html
