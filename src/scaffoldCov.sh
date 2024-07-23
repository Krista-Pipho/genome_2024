#!/bin/bash
#SBATCH --mem=50G
#SBATCH --cpus-per-task=24
#SBATCH --partition scavenger
#SBATCH --array=0-114
#114 lines aka scaffolds in the fai for 2011

module load Java/1.8.0_60
module load samtools/1.9

readarray -t scaffoldArr < ../results/2011_align/hmr.p_ctg_masked_linearized.fa.fai

#cut is -d delimiter of space, -f 1 is field 1
scaffoldName=$(echo ${scaffoldArr[$SLURM_ARRAY_TASK_ID]} | cut -d ' ' -f 1)
scaffoldLen=$(echo ${scaffoldArr[$SLURM_ARRAY_TASK_ID]} | cut -d ' ' -f 2)
samplePoints=$((scaffoldLen/100))
ssamplePoints=${samplePoints%.*}


echo $scaffoldName
plotCoverage --skipZeros -b ../results/2011_align/S1.dedup.masked.bam ../results/2011_align/S2.dedup.masked.bam ../results/2011_align/S3.dedup.masked.bam ../results/2011_align/S4.dedup.masked.bam --plotFile ../results/2011_align/maskedCov/skip/${scaffoldName}_coverage  --outRawCounts ../results/2011_align/maskedCov/skip/${scaffoldName}_cov.tab --region $scaffoldName -n $samplePoints &> "../results/2011_align/maskedCov/skip/${scaffoldName}_coverageStats.txt"
#plotCoverage -b S1.bc2010.dedup.bam S2.dedup.bam S3.dedup.bam S4.dedup.bam --plotFile utg000001l_coverage --outRawCounts utg000001l_cov.tab --region utg000001l -n 7178

#means    
averages=""

while read sample mean std min p25 p50 p75 max; do
    averages="${averages} ${mean}"
done < ../results/2011_align/maskedCov/skip/${scaffoldName}_coverageStats.txt

averages=$(echo "$averages" | awk '{print $2 " " $3 " " $4 " " $5}')
touch ../results/2011_align/maskedCov/skip/scaffoldCov.txt | echo $scaffoldName $averages | tr ' ' '\t' >> ../results/2011_align/maskedCov/skip/scaffoldCov.txt
