#!/bin/bash
#SBATCH --mem=200G
#SBATCH --cpus-per-task 64
#SBATCH --partition scavenger


REF=../results/2011_align/bc2011.asm.p_ctg.fa #file needs to be indexable to be a reference (able to make fai from faidx aka rm S from hifi)
R1=/work/kp275/20240425_gynandromorph_data_wip/TN2L_S1/TN2L_S1_1.fastq.gz
R2=/work/kp275/20240425_gynandromorph_data_wip/TN2L_S1/TN2L_S1_2.fastq.gz
BAM=../results/2011_align/S1.bam
DEDUP_BAM=../results/2011_align/S1.dedup.bam

#S1


module load BWA/0.7.17   
module load Java/1.8.0_60
#REF is reference, R1 is forward, R2 is backward reads, dedup is deduplicated
bwa index ${REF}
samtools faidx ${REF}
java -jar ../../picard.jar CreateSequenceDictionary R=${REF}
 
bwa mem -M -t 32 ${REF} ${R1} ${R2}| samtools sort -@32 - -o ${BAM}
samtools index ${BAM} -@32

PICARD_JAR=../../picard.jar
RUN_PICARD="java -jar -Xmx7g ${PICARD_JAR}"

#which reads r from pcr duplicates and throw em out
${RUN_PICARD} MarkDuplicates INPUT=${BAM} OUTPUT=${DEDUP_BAM} METRICS_FILE=metrics.txt  VALIDATION_STRINGENCY=LENIENT
 
samtools index ${DEDUP_BAM} -@32
