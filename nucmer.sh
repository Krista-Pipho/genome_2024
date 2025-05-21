#!/bin/bash
#SBATCH --mem=50G
#SBATCH -c32
#SBATCH --partition=scavenger

/hpc/home/kp275/bin/mummer-4.0.0rc1/nucmer hmel2.5.gfa hmr.gfa 
