all_samples=["SRR13577847"]
cores="10" # Number of cores, where required to specify 
busco_lineage="saccharomycetes" # Find here https://busco.ezlab.org/list_of_lineages.html
tidk_lineage="Lepidoptera" # Find here https://github.com/tolkit/a-telomeric-repeat-database

rule targets:
	input:
		expand("analysis/{sample}/genomescope_{sample}/linear_plot.png", sample=all_samples), #fasta_qc
		expand("analysis/{sample}/{sample}.p_ctg.fa", sample=all_samples), #assembly
		expand("analysis/{sample}/{sample}.p_ctg.fa.fai", sample=all_samples), #indexing
		expand("analysis/{sample}/busco_{sample}/full_table.tsv", sample=all_samples), #busco
#		expand("analysis/{sample}/tidk_{sample}.svg", sample=all_samples), #telo
		expand("analysis/{sample}/quast_{sample}/report.txt", sample=all_samples), #quast
		expand("results/{sample}/{sample}_busco_table.txt", sample=all_samples), #results 
#		expand("analysis/{sample}/../analysis/snake/{sample}.bp.p_ctg.gfa", sample=all_samples), #assembly
#		expand("../logs/{sample}.log", sample=all_samples),
#		expand("../analysis/{sample}.linear_plot.png", sample=all_samples), #fasta_qc
#		"../analysis/allAnnotation_{sample}.gff" #annotations
        
rule data_qc:
	input:
		hifi_reads="{sample}.fa"
	output:
		genomescope="analysis/{sample}/genomescope_{sample}/linear_plot.png"
	shell:
		"""
		# Make intermediate files for genomescope analysis using Jellyfish
		# Find more information here. -m is kmer length, -s is memory, -t is threads
		jellyfish count -C -m 20 -s 1000000000 -t {cores} {input.hifi_reads} -o analysis/{wildcards.sample}/{wildcards.sample}.jf
		jellyfish histo -t 10 analysis/{wildcards.sample}/{wildcards.sample}.jf > analysis/{wildcards.sample}/{wildcards.sample}.histo
		
		# Run genomescope
		genomescope2 -i analysis/{wildcards.sample}/{wildcards.sample}.histo -o analysis/{wildcards.sample}/genomescope_{wildcards.sample} -k 20 #kmer_size
		"""

rule assembly:
	input:
		hifi_reads="{sample}.fa"
	output:
		"analysis/{sample}/{sample}.p_ctg.fa",
	shell:
		"""
		# To see or change details of the assembly, open assembly.sh
		bash assembly.sh {wildcards.sample} {input.hifi_reads}
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
		full="analysis/{sample}/busco_{sample}/full_table.tsv"
	shell:
		"""
		# Use singularity docker to run BUSCO using the specific lineage entered at the top of this file
		# BUSCO generates both a summary with percent of genes found, and a full output of each gene location
		singularity exec docker://ezlabgva/busco:v5.4.7_cv1 busco -i {input.assembly} -f --cpu {cores} -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno
		
		# Moves the BUSCO output to a location that snakemake can understand
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run*/short_summary.txt analysis/{wildcards.sample}/busco_{wildcards.sample}/short_summary.txt
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run*/full_table.tsv  analysis/{wildcards.sample}/busco_{wildcards.sample}/full_table.tsv
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
		genomescope="analysis/{sample}/genomescope_{sample}/linear_plot.png",	
		report="analysis/{sample}/quast_{sample}/report.txt",
		summary="analysis/{sample}/busco_{sample}/",

	output:
		genomescope_copy="results/{sample}/{sample}_genomescope.png",   
		index_copy="results/{sample}/{sample}.fa.fai",
		quast_report="results/{sample}/{sample}_quast_table.txt",
		busco_summary="results/{sample}/{sample}_busco_table.txt",
		busco_full="results/{sample}/{sample}_full_busco_table.txt",

	shell:
		"""
		# Copy genomescope output to the results folder
		cp {input.genomescope} {output.genomescope_copy}
		
		# Because the index has information about scaffold number and size this file is copied to the results folder 
		cp {input.index} {output.index_copy}
		
		# Modify BUSCO outputs to make them compatible with the downstream visualization tools provided. Store in results
		# Modify QUAST outputs to make them compatible with the downstream visualization tools provided. Store in results
		bash summarize.sh {wildcards.sample} {input.report} {output.quast_report} {input.summary} {output.busco_summary} {output.busco_full}
		"""
rule masking:
	input: 
		"../analysis/snake/{sample}.bp.p_ctg.gfa"
	output:
		"../analysis/{sample}.bp.p_ctg.masked.fasta"
	shell:
		"""
		bash scripts/maskingFasta.py"
		"""

rule geneAnnotations:
	input:
		"../analysis/{sample}.bp.p_ctg.masked.fasta"
	output:
		"../analysis/geneAnnotation_{sample}.gff"
	script:
		"scripts/geneGFF.py" 

rule noncodingAnnotations:
	input:
		"../analysis/{sample}.bp.p_ctg.masked.fasta"
	output:
		"../analysis/noncodingAnnotation_{sample}.gff"
	script:
		"scripts/noncodingGFF.py" 

rule combinedGFF:
	input:
		"../analysis/geneAnnotation_{sample}.gff",
		"../analysis/noncodingAnnotation_{sample}.gff"
	output:
		"../analysis/allAnnotation_{sample}.gff"
	script:
		"combineGFF.py"
