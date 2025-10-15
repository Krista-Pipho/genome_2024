import os
import certifi
os.environ['SSL_CERT_FILE'] = certifi.where()

configfile: "config.yaml"

all_samples = config["sample"]
cores = config["cores"]
busco_lineage = config["busco_lineage"]
tidk_lineage = config["tidk_lineage"]

rule targets:
	input:
	#	expand("analysis/{sample}/genomescope_{sample}/linear_plot.png", sample=all_sample), #fasta_qc
		expand("analysis/{sample}/{sample}.p_ctg.fa", sample=all_samples), #assembly
		expand("analysis/{sample}/{sample}.p_ctg.fa.fai", sample=all_samples), #indexing
		expand("analysis/{sample}/busco_{sample}/short_summary.txt", sample=all_samples, busco_lineage=busco_lineage), #busco
	#	expand("analysis/{sample}/tidk_{sample}.svg", sample=all_samples), #telo
		expand("analysis/{sample}/quast_{sample}/report.txt", sample=all_samples), #quast
		expand("results/{sample}/{sample}_busco_table.txt", sample=all_samples), #results 
        


rule data_qc:
	input:
		hifi_reads="{sample}.fa"
	output:
		genomescope="analysis/{sample}/genomescope_{sample}/linear_plot.png",
		genomescope_copy="results/{sample}/{sample}_genomescope.png" 
	shell:
		"""
		# Make intermediate files for genomescope analysis using Jellyfish
		# Find more information here. -m is kmer length, -s is memory, -t is threads
		jellyfish count -C -m 20 -s 1000000000 -t {cores} {input.hifi_reads} -o analysis/{wildcards.sample}/{wildcards.sample}.jf
		jellyfish histo -t 10 analysis/{wildcards.sample}/{wildcards.sample}.jf > analysis/{wildcards.sample}/{wildcards.sample}.histo
		
		# Run genomescope
		genomescope2 -i analysis/{wildcards.sample}/{wildcards.sample}.histo -o analysis/{wildcards.sample}/genomescope_{wildcards.sample} -k 20 #kmer_size	

		# Copy genomescope output to the results folder
		cp {output.genomescope} {output.genomescope_copy}
		"""

rule assembly:
	input:
		hifi_reads="{sample}.fa"
	output:
		"analysis/{sample}/{sample}.p_ctg.fa",
	shell:
		"""
		# To see or change details of the assembly, open assembly.sh
		bash assembly.sh {wildcards.sample} {input.hifi_reads} {cores}
		"""
rule index:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		index="analysis/{sample}/{sample}.p_ctg.fa.fai"
	shell:
		"""
		# Index the newly assembled genome
		samtools faidx {input.assembly}
		"""
rule busco:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		summary="analysis/{sample}/busco_{sample}/short_summary.txt",
		full="analysis/{sample}/busco_{sample}/full_table.tsv",
	shell:
		"""
		# Use singularity docker to run BUSCO using the specific lineage entered at the top of this file
		# BUSCO generates both a summary with percent of genes found, and a full output of each gene location
		singularity exec -B $(pwd) docker://ezlabgva/busco:v6.0.0_cv1 busco -i {input.assembly} -f --cpu {cores} -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno
		#busco -i {input.assembly} -f --cpu {cores} -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno
		# Moves the BUSCO output to a location that snakemake can understand
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb12/short_summary.txt analysis/{wildcards.sample}/busco_{wildcards.sample}/short_summary.txt
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb12/full_table.tsv  analysis/{wildcards.sample}/busco_{wildcards.sample}/full_table.tsv
		"""

rule telo:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		"analysis/{sample}/tidk_{sample}.svg"
	shell:
		"""
		# To see or change details of telomere finding, open telomere.sh
		bash telomere.sh {wildcards.sample} {input.assembly} {tidk_lineage}
		"""

rule quast:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		report="analysis/{sample}/quast_{sample}/report.txt"
	shell:
		"""
		# Run quast 
		quast -o analysis/{wildcards.sample}/quast_{wildcards.sample} {input.assembly}
		"""

rule clean_results:
	input: 
		index="analysis/{sample}/{sample}.p_ctg.fa.fai",
		report="analysis/{sample}/quast_{sample}/report.txt",
		summary="analysis/{sample}/busco_{sample}/short_summary.txt",
		full="analysis/{sample}/busco_{sample}/full_table.tsv",

	output:
		index_copy="results/{sample}/{sample}.fa.fai",
		quast_report="results/{sample}/{sample}_quast_table.txt",
		busco_summary="results/{sample}/{sample}_busco_table.txt",
		busco_full="results/{sample}/{sample}_full_busco_table.txt",

	shell:
		"""
		# Because the index has information about scaffold number and size this file is copied to the results folder 
		cp {input.index} {output.index_copy}
		
		# Modify BUSCO outputs to make them compatible with the downstream visualization tools provided. Store in results
		# Modify QUAST outputs to make them compatible with the downstream visualization tools provided. Store in results
		bash summarize.sh {wildcards.sample} {input.report} {output.quast_report} {input.summary} {input.full} {output.busco_summary} {output.busco_full}
		"""

