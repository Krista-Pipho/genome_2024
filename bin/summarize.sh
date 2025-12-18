#!/bin/bash

sample=$1
quast_in=$2
quast_out=$3
busco_summary=$4
busco_full=$5
busco_summary_out=$6
busco_full_out=$7

# Modify QUAST outputs to make them compatible with the downstream visualization tools provided. Store in results
echo $sample > $quast_out
cat $quast_in | grep "contigs (>= 0 bp) " | awk -F '  +' '{print $2}' >> $quast_out
cat $quast_in | grep L50 | awk -F '  +' '{print $2}' >> $quast_out
cat $quast_in | grep L75 | awk -F '  +' '{print $2}' >> $quast_out

# Modify BUSCO outputs to make them compatible with the downstream visualization tools provided. Store in results
echo $sample > $busco_summary_out
cat $busco_summary | grep "C:" | awk -F "[:,%]" '{print  $2 "\n" $7 "\n" $13}' >> $busco_summary_out
echo -e "Busco_id\tStatus\tSequence\tGene_Start\tGene_End\tStrand\tScore\tLength\tOrthoDB_url\tDescription" > $busco_full_out # Fixes the header of full
sed 1,3d $busco_full >> $busco_full_out # Copies the data of full