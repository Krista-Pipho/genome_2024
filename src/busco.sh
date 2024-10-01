#!/bin/bash
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48
#SBATCH --partition scavenger
singularity exec -B /hpc/group/wraylab:/hpc/group/wraylab docker://ezlabgva/busco:v5.4.7_cv1 busco -i /work/kp275/clean_run_hifi/reads/hed.p_ctg.fa -l lepidoptera -o busco_output/hed -m geno