import os
import certifi
os.environ['SSL_CERT_FILE'] = certifi.where()

configfile: "config.yaml"

assembly = config["sample"]
cores = config["cores"]
rule all:
    input:
        expand("analysis/{assembly}/masking/{assembly}_masked.bedtools", assembly=assembly)

rule repeat_modeling:
    input:
        "{assembly}.gfa"
    output:
        "analysis/{assembly}/masking/consensi.fa.classified"
    shell:
        """
        if [ ! -d "analysis/{assembly}/masking" ]; then		
			mkdir analysis/{assembly}/masking
		fi
        cp {assembly}.gfa analysis/{assembly}/masking/
        cd analysis/{assembly}/masking
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest BuildDatabase -name {assembly}_masking {assembly}.gfa 
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest RepeatModeler -database {assembly}_masking -engine ncbi -threads 60 -dir ./
        cd ../../..
        """

rule repeat_masking:
    input:
        library="analysis/{assembly}/masking/consensi.fa.classified",
    output:
        gff="analysis/{assembly}/masking/{assembly}.gfa.out.gff", 
        masked_result="results/{assembly}/{assembly}_masked.fasta"
    shell:
        """
        cd analysis/{assembly}/masking
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest RepeatMasker -pa 60 -gff -lib consensi.fa.classified -dir ./ {assembly}.gfa
        cp {assembly}.gfa.masked ../../../results/{assembly}/{assembly}_masked.fasta
        cd ../../..
        """

rule masking_summary:
    input:
        gff="analysis/{assembly}/masking/{assembly}.gfa.out.gff"
    output:
        "analysis/{assembly}/masking/{assembly}_masked.bedtools"
    shell:
        """
        cd analysis/{assembly}/masking
        samtools faidx {assembly}.gfa.masked
        awk -v OFS='\t' {{'print $1,$2'}} {assembly}.gfa.masked.fai > {assembly}.gfa.masked.bedtools
        pixi run bedtools summary -i {assembly}.gfa.out.gff -g {assembly}.gfa.masked.bedtools
        cd ../../..
        """
        


