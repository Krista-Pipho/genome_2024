import os
import certifi
os.environ['SSL_CERT_FILE'] = certifi.where()

configfile: "config.yaml"

all_samples = [config["sample"], config["compare_assembly"]]
cores = config["cores"]
busco_lineage = config["busco_lineage"]


### Conditional Operations
filter_reads = config["filter_reads"]
run_genomescope = config["run_genomescope"]
assemble_mito = config["assemble_mito"]
find_telomeres = config["find_telomeres"]
generate_data_for_dotplot = config["generate_data_for_dotplot"]

### Values needed by conditional operations
kraken_database = config["kraken_database"]
tidk_lineage = config["tidk_lineage"]
oatk_db = config["oatk_db"]


all_targets = [
		#expand("analysis/{sample}/{sample}.p_ctg.fa", sample=all_samples), #assembly
		#expand("analysis/{sample}/{sample}.p_ctg.fa.fai", sample=all_samples), #indexing
		#expand("analysis/{sample}/busco_{sample}/short_summary.txt", sample=all_samples, busco_lineage=busco_lineage), #busco
		#expand("analysis/{sample}/quast_{sample}/report.txt", sample=all_samples), #quast
		expand("results/{sample}/{sample}_busco_table.txt", sample=all_samples), # make results summary
		expand("{primary_assembly}_{compare_assembly}_assembly_summary.html", primary_assembly=all_samples[0], compare_assembly=all_samples[1]) # generate final summary html report
]

if filter_reads == True:
	all_targets.append(expand("results/{sample}/{sample}.report", sample=all_samples[0]))

if run_genomescope == True:
	all_targets.append(expand("analysis/{sample}/genomescope_{sample}/linear_plot.png", sample=all_samples[0]))

if assemble_mito == True:
	all_targets.append(expand("results/{sample}/{sample}.mito.bed", sample=all_samples[0]))

if find_telomeres == True:
	all_targets.append(expand("analysis/{sample}/tidk_{sample}.svg", sample=all_samples))	

if generate_data_for_dotplot == True:
	all_targets.append(expand("results/{sample}/{sample}_{compare_assembly}.coords", sample=all_samples[0], compare_assembly=all_samples[1]))
	all_targets.append(expand("results/{sample}/{sample}_{compare_assembly}.coords", sample=all_samples[1], compare_assembly=all_samples[0]))

rule targets:
	input:		
		all_targets

rule download_reads:
	output:
		"{sample}.fastq"
	shell:
		"""
		singularity exec -B $(pwd) docker://ncbi/sra-tools fasterq-dump {wildcards.sample}
		"""

rule kraken:
	input: 
		reads="{sample}.fastq"
	output:
		unfiltered="analysis/{sample}/{sample}_unfiltered.fastq",
		contaminants="analysis/{sample}/{sample}_classified.fq",
		report="results/{sample}/{sample}.report",
	shell:
		"""
		kraken_db={kraken_database}

		if [ ! -d "$kraken_db" ]; then
			echo "$kraken_db does not exist."		
			mkdir {kraken_database}
			cd {kraken_database}

			# Downloads zipped database, extracts database files, and removes the zipped file
			echo "Downloading $kraken_db"
			wget -q https://genome-idx.s3.amazonaws.com/kraken/{kraken_database}.tar.gz
			tar -xf {kraken_database}.tar.gz
			rm {kraken_database}.tar.gz
			cd ..
		fi

		singularity exec -B $(pwd) docker://staphb/kraken2 kraken2 --db {kraken_database} --threads {cores} --confidence .1 --unclassified-out analysis/{wildcards.sample}/unclassified_{wildcards.sample}.fq --classified-out {output.contaminants} --output analysis/{wildcards.sample}/kraken.output --report {output.report} {input.reads}
		
		# Stores original reads in a file labled unfiltered
		mv {input.reads} {output.unfiltered}
		# Moves the filtered reads not classified by kraken as a comtaminant to sample.fastq for downstream analysis
		mv analysis/{wildcards.sample}/unclassified_{wildcards.sample}.fq {wildcards.sample}.fastq 
		"""

qc_input = []
if filter_reads == True:
	qc_input.append("results/{sample}/{sample}.report")

rule data_qc:
	input:
		hifi_reads="{sample}.fastq", 
		optional_input=qc_input
	output:
		genomescope="analysis/{sample}/genomescope_{sample}/linear_plot.png",
		genomescope_copy="results/{sample}/{sample}_genomescope.png" 
	shell:
		"""
		# Make intermediate files for genomescope analysis using Jellyfish
		# Find more information here. -m is kmer length, -s is memory, -t is threads
		singularity exec -B $(pwd) docker://biodckrdev/jellyfish:2.2.3 jellyfish count -C -m 20 -s 1000000000 -t {cores} {input.hifi_reads} -o analysis/{wildcards.sample}/{wildcards.sample}.jf
		singularity exec -B $(pwd) docker://biodckrdev/jellyfish:2.2.3 jellyfish histo -t 10 analysis/{wildcards.sample}/{wildcards.sample}.jf > analysis/{wildcards.sample}/{wildcards.sample}.histo

		# Run genomescope
		genomescope2 -i analysis/{wildcards.sample}/{wildcards.sample}.histo -o analysis/{wildcards.sample}/genomescope_{wildcards.sample} -k 20 #kmer_size	

		# Copy genomescope output to the results folder
		cp {output.genomescope} {output.genomescope_copy}
		"""

rule oatk:
	input:
		hifi_reads="{sample}.fastq"
	output:
		mito_assembly="results/{sample}/{sample}.mito.bed"
	shell:
		"""
		oatk_db={oatk_db}

		if [ ! -d "OatkDB" ]; then
			echo "OatkDB  does not exist."		
			git clone https://github.com/c-zhou/OatkDB.git
		fi

		pixi run oatk -t {cores} -m {oatk_db} -o analysis/{wildcards.sample}/{wildcards.sample} {wildcards.sample}.fastq
		cp analysis/{wildcards.sample}/{wildcards.sample}.mito.bed results/{wildcards.sample}/{wildcards.sample}.mito.bed
		cp analysis/{wildcards.sample}/{wildcards.sample}.mito.gfa results/{wildcards.sample}/{wildcards.sample}.mito.gfa
		"""

assembly_input = []
if filter_reads == True:
	assembly_input.append("results/{sample}/{sample}.report")
rule assembly:
	input:
		hifi_reads="{sample}.fastq",
		optional_input=assembly_input
	output:
		hifiasm_output="analysis/{sample}/{sample}.bp.p_ctg.gfa",
		assembly="{sample}.gfa"
	shell:
		"""
		# To see or change details of the assembly, open assembly.sh
		bash bin/assembly.sh {wildcards.sample} {input.hifi_reads} {cores}
		"""

rule index:
	input:
		assembly="{sample}.gfa"
	output:
		index="analysis/{sample}/{sample}.gfa.fai"
	shell:
		"""
		# Index the newly assembled genome
		samtools faidx --fai-idx analysis/{wildcards.sample}/{input.assembly}.fai {input.assembly}
		"""

rule busco:
	input:
		assembly="{sample}.gfa"
	output:
		summary="analysis/{sample}/busco_{sample}/short_summary.txt",
		full="analysis/{sample}/busco_{sample}/full_table.tsv",
	shell:
		"""
		# Use singularity docker to run BUSCO using the specific lineage entered at the top of this file
		# BUSCO generates both a summary with percent of genes found, and a full output of each gene location
		singularity exec -B $(pwd) docker://ezlabgva/busco:v6.0.0_cv1 busco -i {input.assembly} -f --cpu {cores} -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno

		# Moves the BUSCO output to a location that snakemake can understand
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb12/short_summary.txt analysis/{wildcards.sample}/busco_{wildcards.sample}/short_summary.txt
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb12/full_table.tsv  analysis/{wildcards.sample}/busco_{wildcards.sample}/full_table.tsv
		"""

rule dotplot:
	input:
		assembly="{sample}.gfa",
		compare_assembly="{compare_assembly}.gfa"
	output:
		"results/{sample}/{sample}_{compare_assembly}.coords",
		"results/{sample}/{sample}_{compare_assembly}.coords.idx"
	shell:
		"""
		singularity exec -B $(pwd) docker://staphb/mummer:4.0.1 nucmer {input.assembly} {input.compare_assembly} -p analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}
		python bin/DotPrep.py --out results/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly} --delta analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.delta
		# To visualize the dotplot, upload the .coords file to the website below
		# https://dot.sandbox.bio/
		"""

rule telo:
	input:
		assembly="{sample}.gfa"
	output:
		"analysis/{sample}/tidk_{sample}.svg"
	shell:
		"""
		# To see or change details of telomere finding, open telomere.sh
		bash bin/telomere.sh {wildcards.sample} {input.assembly} {tidk_lineage}
		"""

rule quast:
	input:
		assembly="{sample}.gfa"
	output:
		report="analysis/{sample}/quast_{sample}/report.txt"
	shell:
		"""
		# Run quast 
		singularity exec -B $(pwd) docker://nanozoo/quast quast -o analysis/{wildcards.sample}/quast_{wildcards.sample} {input.assembly}
		"""

rule clean_results:
	input: 
		index="analysis/{sample}/{sample}.gfa.fai",
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
		bash bin/summarize.sh {wildcards.sample} {input.report} {output.quast_report} {input.summary} {input.full} {output.busco_summary} {output.busco_full}
		"""

rule render_summary_rmd:
	input:
		primary_summary = expand("results/{sample}/{sample}_full_busco_table.txt", sample=all_samples[0]),
		compare_summary = expand("results/{sample}/{sample}_full_busco_table.txt", sample=all_samples[1])
	output:
		summary=expand("{primary_assembly}_{compare_assembly}_assembly_summary.html", primary_assembly=all_samples[0], compare_assembly=all_samples[1])
	shell:
		"""
		pixi run Rscript -e "rmarkdown::render('assembly_pipeline_summary.Rmd', output_file='{output.summary}', param=list(primary_genome='{all_samples[0]}',compare_genome='{all_samples[1]}'))"
		"""

