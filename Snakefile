### Import Statements
import os
import certifi
os.environ['SSL_CERT_FILE'] = certifi.where()

configfile: "config.yaml"

### Config Variables needed by required steps
all_samples = [config["sample"], config["compare_assembly"]]
cores = config["cores"]
busco_lineage = config["busco_lineage"]

### Optional Steps selected in config file
filter_reads = config["filter_reads"]
run_genomescope = config["run_genomescope"]
assemble_mito = config["assemble_mito"]
find_telomeres = config["find_telomeres"]
generate_data_for_dotplot = config["generate_data_for_dotplot"]
repeat_masking = config["repeat_masking"]

### Config Variables needed by optional steps
kraken_database = config["kraken_database"]
tidk_lineage = config["tidk_lineage"]
oatk_db = config["oatk_db"]

### Final output file for required steps
all_targets = [
		#expand("analysis/{sample}/{sample}.p_ctg.fa", sample=all_samples), #assembly
		#expand("analysis/{sample}/{sample}.p_ctg.fa.fai", sample=all_samples), #indexing
		#expand("analysis/{sample}/busco_{sample}/short_summary.txt", sample=all_samples, busco_lineage=busco_lineage), #busco
		#expand("analysis/{sample}/quast_{sample}/report.txt", sample=all_samples), #quast
		expand("results/{sample}/{sample}_busco_table.txt", sample=all_samples), # make results summary
		expand("{primary_assembly}_{compare_assembly}_assembly_summary.html", primary_assembly=all_samples[0], compare_assembly=all_samples[1]) # generate final summary html report
]

### Optional Steps output file logic (Appended to all_targets)
if filter_reads == True:
	all_targets.append(expand("results/{sample}/{sample}.filtering.report", sample=all_samples[0]))

if run_genomescope == True:
	all_targets.append(expand("analysis/{sample}/genomescope_{sample}/linear_plot.png", sample=all_samples[0]))

if assemble_mito == True:
	all_targets.append(expand("results/{sample}/{sample}.mito.bed", sample=all_samples[0]))

if find_telomeres == True:
	all_targets.append(expand("analysis/{sample}/tidk_{sample}.svg", sample=all_samples))	

if generate_data_for_dotplot == True:
	all_targets.append(expand("results/{sample}/{sample}_{compare_assembly}.coords", sample=all_samples[0], compare_assembly=all_samples[1]))
	all_targets.append(expand("results/{sample}/{sample}_{compare_assembly}.coords.idx", sample=all_samples[0], compare_assembly=all_samples[1]))

if repeat_masking == True:
	all_targets.append(expand("results/{sample}/{sample}_masked.fasta", sample=all_samples[0]))
	all_targets.append(expand("results/{sample}/{sample}_masked.bedtools", sample=all_samples[0]))

rule targets:
	input:		
		all_targets

# Download reads from SRA using fasterq-dump
rule download_reads:
	output:
		"{sample}.fastq"
	shell:
		"""
		singularity exec -B $(pwd) docker://ncbi/sra-tools fasterq-dump {wildcards.sample}
		"""

# If filter_reads is selected, removes comtaminating reads using kraken2
rule kraken:
	input: 
		reads="{sample}.fastq"
	output:
		unfiltered="analysis/{sample}/{sample}_unfiltered.fastq", # Reads not assigned to taxa in contaminant database kept
		contaminants="analysis/{sample}/{sample}_classified.fq", # Reads assigned to taxa in contaminant database removed
		report="results/{sample}/{sample}.filtering.report",
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

# If filter_reads is selected, completion of the kraken rule is required before data_qc
qc_input = []
if filter_reads == True:
	qc_input.append("results/{sample}/{sample}.filtering.report")

# If run_genomescope is selected, model read quality and genome characteristics using genomescope2
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

# If assemble_mito is selected, assembly of mitochondrial genome is run using oatk
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

# If filter_reads is selected, completion of the kraken rule is required before assembly
assembly_input = []
if filter_reads == True:
	assembly_input.append("results/{sample}/{sample}.filtering.report")

# Genome assembly using hifiasm
rule assembly:
	input:
		hifi_reads="{sample}.fastq",
		optional_input=assembly_input
	output:
		hifiasm_output="analysis/{sample}/{sample}.bp.p_ctg.gfa",
		assembly="{sample}.gfa"
	shell:
		"""
		# To see or change details of the assembly, open bin/assembly.sh
		bash bin/assembly.sh {wildcards.sample} {input.hifi_reads} {cores}
		"""

# Index the assembled genome using samtools faidx
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

# Assess genome completeness using BUSCO
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
		singularity exec -B $(pwd) docker://ezlabgva/busco:v5.5.0_cv1 busco -i {input.assembly} -f --cpu {cores} -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno

		# Moves the BUSCO output to a location that snakemake can understand
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb10/short_summary.txt analysis/{wildcards.sample}/busco_{wildcards.sample}/short_summary.txt
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run_{busco_lineage}_odb10/full_table.tsv  analysis/{wildcards.sample}/busco_{wildcards.sample}/full_table.tsv
		"""

# If generate_data_for_dotplot is selected, prepare sample x compare_assembly whole genome alignment data using MUMmer
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
		python bin/DotPrep.py --out analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly} --delta analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.delta
		cp analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.coords results/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.coords
		cp analysis/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.coords.idx results/{wildcards.sample}/{wildcards.sample}_{wildcards.compare_assembly}.coords.idx
		# To visualize the dotplot, upload the .coords and .coords.idx files to the website below
		# https://dot.sandbox.bio/
		"""

# If find_telomeres is selected, identify telomeric repeats using tidk
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

# Assess assembly contiguity using QUAST
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

# If repeat_masking is selected and no consensi file is provided, generate a library of repetative sequences using RepeatModeler
rule repeat_modeling:
    input:
        assembly="{sample}.gfa"
    output:
        "analysis/{sample}/masking/consensi.fa.classified"
    shell:
        """
        if [ ! -d "analysis/{wildcards.sample}/masking" ]; then		
			mkdir analysis/{wildcards.sample}/masking
        fi
        
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest BuildDatabase -name analysis/{wildcards.sample}/masking/{wildcards.sample}_masking {wildcards.sample}.gfa 
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest RepeatModeler -database analysis/{wildcards.sample}/masking/{wildcards.sample}_masking -engine ncbi -threads 60 -quick -dir analysis/{wildcards.sample}/masking/
        """

# If repeat_masking is selected, use a repeat library consensi file to mask the assembly using RepeatMasker
rule repeat_masking:
    input:
        library="analysis/{sample}/masking/consensi.fa.classified",
    output:
        gff="analysis/{sample}/masking/{sample}.gfa.out.gff", 
        masked_result="results/{sample}/{sample}_masked.fasta"
    shell:
        """
        pixi run singularity exec -B $(pwd) docker://dfam/tetools:latest RepeatMasker -pa 60 -gff -lib analysis/{wildcards.sample}/masking/consensi.fa.classified -dir analysis/{wildcards.sample}/masking/ {wildcards.sample}.gfa
        cp analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.masked results/{wildcards.sample}/{wildcards.sample}_masked.fasta
        """

# If repeat_masking is selected, generate a summary of masked regions using bedtools
rule masking_summary:
    input:
        gff="analysis/{sample}/masking/{sample}.gfa.out.gff"
    output:
        "results/{sample}/{sample}_masked.bedtools"
    shell:
        """
        samtools faidx analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.masked
        awk -v OFS='\t' {{'print $1,$2'}} analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.masked.fai > analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.masked.bedtools
        pixi run bedtools summary -i analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.out.gff -g analysis/{wildcards.sample}/masking/{wildcards.sample}.gfa.masked.bedtools > analysis/{wildcards.sample}/masking/{wildcards.sample}_masked.bedtools
        cp analysis/{wildcards.sample}/masking/{wildcards.sample}_masked.bedtools results/{wildcards.sample}/{wildcards.sample}_masked.bedtools
        """

# Use custom code found in bin/summarize.sh to clean and summarize workflow outputs for downstream visualization
# Cleaned results are aggregated and stored in the results/sample folder (These can be accessed even if summary rendering fails)
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

# Generate visual final summary report in html format using Rmarkdown
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

