#!/bin/bash
#SBATCH --mem=200G
#SBATCH --cpus-per-task 64
#SBATCH --partition scavenger

#either charithonia or congener (sbatch mummerBlast.sh charithonia)

../bin/mummer-4.0.0rc1/nucmer -p ../results/2011_align/W_bc2011.masked.$1.sensitive  ../results/2011_align/W_bc2011.masked.fasta  ../results/2011_align/W_H.$1.fasta -c 30 -l 10
#10 5, is 13334197

python ../bin/dot/DotPrep.py --delta ../results/2011_align/W_bc2011.masked.$1.sensitive.delta  --out ../results/2011_align/W_bc2011.masked.$1.sensitive.dotPrep


#mummer the two published Ws against each other 
#../bin/mummer-4.0.0rc1/nucmer -p ../results/2011_align/W_charithonia.congener  ../results/2011_align/W_H.charithonia.fasta  ../results/2011_align/W_H.congener.fasta

#python ../bin/dot/DotPrep.py --delta ../results/2011_align/W_charithonia.congener.delta  --out ../results/2011_align/W_charithonia.congener.dotPrep

