#!/bin/bash
#SBATCH --mem=200G
#SBATCH --cpus-per-task 64
#SBATCH --partition scavenger

#r1=s1, r2=-s2, bam=3, dedup_bam=4
REF=../results/readAlign/bc2010.asm.p_utg.fa #file needs to be indexable to be a reference (able to make fai from faidx aka rm S from hifi)
R1=/work/kp275/20240425_gynandromorph_data_wip/TN2R_S2/TN2R_S2_1.fastq.gz 
R2=/work/kp275/20240425_gynandromorph_data_wip/TN2R_S2/TN2R_S2_2.fastq.gz
BAM=../results/readAlign/S2.bam
DEDUP_BAM=../results/readAlign/S2.dedup.bam

#S1


module load BWA/0.7.17   
module load Java/1.8.0_60
#REF is reference, R1 is forward, R2 is backward reads, dedup is deduplicated -> run 3 lines below once to do ref genome, then
#dont need to run anymore 
#bwa index ${REF}
#samtools faidx ${REF}
#java -jar ../../picard.jar CreateSequenceDictionary R=${REF}
 
bwa mem -M -t 32 ${REF} $1 $2| samtools sort -@32 - -o $3
samtools index $3 -@32

PICARD_JAR=../../picard.jar
RUN_PICARD="java -jar -Xmx7g ${PICARD_JAR}"

#which reads r from pcr duplicates and throw em out
${RUN_PICARD} MarkDuplicates INPUT=$3 OUTPUT=$4 METRICS_FILE=metrics.txt  VALIDATION_STRINGENCY=LENIENT
 
samtools index $4 -@32
