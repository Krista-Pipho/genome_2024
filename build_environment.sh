#!/bin/bash
#SBATCH --mem=50G
#SBATCH -c32
#SBATCH --partition=scavenger

conda env create -f environment.txt
