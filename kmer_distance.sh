#!/bin/bash
#SBATCH --mem=50G
#SBATCH --partition scavenger

assembly=$1
outdir="analysis/${assembly}/${assembly}_outputs"

if [ ! -d $outdir ]; then
			mkdir $outdir
fi

while IFS= read -r line; do contig_name=$(echo $line | cut -d ' ' -f 1 ); samtools faidx ${assembly}.gfa ${contig_name} > ${outdir}/${contig_name}.fa; done < analysis/${assembly}/${assembly}.gfa.fai 

ls $outdir/*.fa > ${outdir}/samples.list


kmer-db build -k 21 -t 30 ${outdir}/samples.list ${outdir}/my_kmer_db.db
# kmer-db all2all ${outdir}/my_kmer_db.db ${outdir}/common_kmer_counts.csv
kmer-db one2all ${outdir}/my_kmer_db.db analysis/${assembly}/${assembly}.mito.ctg.fasta ${outdir}/common_kmer_counts.csv

# Calculate Jaccard distance
kmer-db distance jaccard ${outdir}/common_kmer_counts.csv ${outdir}/jaccard_distances.csv

# Calculate ANI (Average Nucleotide Identity)
kmer-db distance ani ${outdir}/common_kmer_counts.csv ${outdir}/ani_distances.csv