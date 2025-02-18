all_samples=["bc2035"]
busco_lineage="lepidoptera" # Find here https://busco.ezlab.org/list_of_lineages.html
tidk_lineage="Lepidoptera" # Find here https://github.com/tolkit/a-telomeric-repeat-database

rule targets:
	input:
		expand("results/{sample}/{sample}_genomescope.png", sample=all_samples), #fasta_qc
		expand("analysis/{sample}/{sample}.p_ctg.fa", sample=all_samples), #assembly
		expand("analysis/{sample}/{sample}.p_ctg.fa.fai", sample=all_samples), #indexing
		expand("analysis/{sample}/{sample}_busco_short_summary.txt", sample=all_samples), #busco
		expand("analysis/{sample}/tidk_{sample}.svg", sample=all_samples), #telo
		expand("analysis/{sample}/{sample}_quast_report.txt", sample=all_samples), #quast
#		expand("analysis/{sample}/../analysis/snake/{sample}.bp.p_ctg.gfa", sample=all_samples), #assembly
#		expand("../logs/{sample}.log", sample=all_samples),
#		expand("../analysis/{sample}.linear_plot.png", sample=all_samples), #fasta_qc
#		"../analysis/allAnnotation_{sample}.gff" #annotations
        
rule data_qc:
	input:
		hifi_reads="{sample}.fa"
	output:
		"results/{sample}/{sample}_genomescope.png"   
	shell:
		"""
		jellyfish count -C -m 20 -s 1000000000 -t 10 {input.hifi_reads} -o analysis/{wildcards.sample}/{wildcards.sample}.jf
		jellyfish histo -t 10 analysis/{wildcards.sample}/{wildcards.sample}.jf > analysis/{wildcards.sample}/{wildcards.sample}.histo
		genomescope2 -i analysis/{wildcards.sample}/{wildcards.sample}.histo -o analysis/{wildcards.sample}/genomescope_{wildcards.sample} -k 20 #kmer_size
		cp analysis/{wildcards.sample}/genomescope_{wildcards.sample}/linear_plot.png results/{wildcards.sample}/{wildcards.sample}_genomescope.png
		"""

rule assembly:
	input:
		hifi_reads="{sample}.fa"
	output:
		"analysis/{sample}/{sample}.p_ctg.fa",
	shell:
		"""
		bash assembly.sh {wildcards.sample} {input.hifi_reads}
		"""
rule index:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		"analysis/{sample}/{sample}.p_ctg.fa.fai"
	shell:
		"""
		samtools faidx {input.assembly}
		cp analysis/{wildcards.sample}/{wildcards.sample}.p_ctg.fa.fai results/{wildcards.sample}/{wildcards.sample}.fa.fai
		"""
rule busco:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		"analysis/{sample}/{sample}_busco_short_summary.txt"
	shell:
		"""
		singularity exec docker://ezlabgva/busco:v5.4.7_cv1 busco -i {input.assembly} -f -l {busco_lineage} -o analysis/{wildcards.sample}/busco_{wildcards.sample} -m geno
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run*/short_summary.txt results/{wildcards.sample}/{wildcards.sample}_busco_short_summary.txt
		cp analysis/{wildcards.sample}/busco_{wildcards.sample}/run*/full_table.tsv results/{wildcards.sample}/{wildcards.sample}_busco_full_table.tsv
		"""

rule telo:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		"analysis/{sample}/tidk_{sample}.svg"
	shell:
		"""
		bash telomere.sh {wildcards.sample} {input.assembly} {tidk_lineage}
		"""

rule quast:
	input:
		assembly="analysis/{sample}/{sample}.p_ctg.fa"
	output:
		"analysis/{sample}/{sample}_quast_report.txt"
	shell:
		"""
		quast -o analysis/{wildcards.sample}/quast_{wildcards.sample} {input.assembly}
		cp analysis/{wildcards.sample}/quast_{wildcards.sample}/report.txt results/{wildcards.sample}/{wildcards.sample}_quast_report.txt	
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
