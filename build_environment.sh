#!/bin/bash
#SBATCH --mem=50G
#SBATCH -c32
#SBATCH --partition=scavenger

conda create -y --name assembly_env --file environment.txt # you can change assembly_env to any name
