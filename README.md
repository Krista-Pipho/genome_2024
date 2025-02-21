# Genome 2024
### Authors: Krista Pipho, Angelina Huang, Avi Heyman, Daniel Levin, and Shriya Minocha

# Description
This Snakemake pipeline is designed for processing PacBio HiFi sequencing data into de-novo genome assemblies. The provided code includes data quality assessment, genome assembly, assembly quality assessment, and gene annotation. Besides de-novo genome assembly, it can evaluate existing genome assemblies and generate comparative statistics. An R markdown document has been provided for visualization of pipeline outputs. The final result is a fully processed and annotated genome, suitable for downstream applications such as comparative genomics, evolutionary studies, and functional analyses. 

In detail, the pipeline accepts PacBio HiFi reads in FASTA or BAM format as **input** and generates the following **outputs**:

* **Data Quality**: GenomeScope2 kmer analysis of HiFi reads (PNG)
* **Genome Assembly**: hifiasm assembled genome sequence (FASTA)
* **Indexing**: Indexed assembly for efficient access (FAI)
* **Completeness Assessment**: BUSCO analysis to evaluate genome completeness (TXT, TSV)
* **Quality Evaluation**: QUAST report with key assembly metrics (TXT)
* **Telomere Identification**: TIDK visualization of telomeric regions (SVG)
* **Masked Assembly**: RepeatMasker masked genome (FASTA)
* **Gene Annotations**: Coding genes (GFF) and noncoding RNA (GFF) annotations


## Requirements
* Any version of conda ie [miniconda](https://docs.anaconda.com/miniconda/install/) or bioconda
* DCC users should follow the instructions here: https://oit-rc.pages.oit.duke.edu/rcsupportdocs/software/user/

<br>

## Getting Started
```
$ # install pipeline
$ git clone https://github.com/Krista-Pipho/genome_2024.git
$ cd genome_2024
$ conda create --name myenv --file environment.txt # change myenv to a functional name
$ conda activate myenv
$ # this environment includes all the packages and other software tools, so no other software downloads are required
```

Creating the environment can take a considerable amount of time, expect 10-60 minutes.

<br> 

**Testing the Pipeline**
<br> 

Using example yeast HIFI reads we will go through a test run of the pipeline and its rules (processes).

1. Download the example data from SRA of accession SRR13577847
```
$ fasterq-dump SRR13577847
$ mv SRR13577847.fastq SRR13577847.fa
``` 

2. Before running the pipeline, first test if workflow is properly installed and estimate the amount of needed resources. Run
```
$ snakemake --dry-run
```
This `--dry-run` flag evaluates the rules without running the actual commands, and also creates a DAG image (`/genome_2024/src/rulegraph.png`) that shows the workflow of all rules. Check if these match.

    a. If on a cluster, the pipeline DAG image (and also any other files) can be viewed by pulling the file from shell to your local computer via `$ scp netid321@dcc-login.oit.duke.edu:/path/to/genome_2024/src/dag.png /local/path/to/save` on local terminal

**INSERT IMG**

3. Then run the pipeline with launch.sh, a file wrapper that contains the Snakemake commands (found within `/src/Snakefile`)  
If on a cluster, 
```
$ sbatch launch.sh
$ # to view job process
$ squeue -u userID 
$ # to monitor live process output, open the corresponding slurm log
```
If not on a cluster,
```
$ ./launch.sh
```

<br> 

**Rule Explanations**
<br> 

Once the pipeline begins running, either open the slurm log or view the terminal output. These following explanations will be based off of the yeast genome

| Rule | Description | Output |
| --- | --- | ---- |
| `data_qc` | **Quality Control**: Analyzes k-mers of sequencing reads to estimate genome characteristics  | `SRR13577847_linear_plot.png`: linear *plot* showing genome size estimation and heterozygosity |
| `assembly` | **Assembly**: Assembles the genome via HiFiASM and extracts primary contigs from assembled graph | `SRR13577847.p_ctg.fa`: assembled genome |
| `index` | **Indexing**: Creates an `samtools` index to allow fast access to genome sequences | `SRR13577847.p_ctg.fa.fai`: index for the assembled genome |
| `busco` | **Genome Completeness**: Identifies the percentage of conserved genes in the assembled genome when given the reference genome | `SRR13577847_busco_short_summary.txt`: summary report with genome completeness scores |
| `telo` | **Telomere Detection**: Identifies any telomeric regions in the genome | `tidk_SRR13577847.svg`: visual showing any telomere presence |
| `quast` | **Genome Structural Evaluation**: Measures genome assembly accuracy and structure | `SRR13577847_quast_report.txt`: report with assembly statistics like N50, GC content, and misassemblies |
| `masking` | **Repeat Masking**: Identifies and masks any repetitive sequences | `../results/SRR13577847.bp.p_ctg.masked.fasta`: masked genome |
| `geneAnnotations` | **Gene Annotation**: Labels protein-coding genes | `../analysis/geneAnnotation_SRR13577847.gff`: gene predictions and labeling |
| `noncodingAnnotations` | **Noncoding Annotation**: Labels noncoding RNA and other regulatory elements | `../analysis/noncodingAnnotation_SRR13577847.gff`: noncoding annotations |
| `combinedGFF` | **Final Annotation Merge**: Combines gene and noncoding annotations into one file | `../analysis/allAnnotation_SRR13577847.gff`: One single annotation file 


## Customizing the Pipeline
editing snakefile, ediitng rules, and assembly+another one is outside in sep file
link snakemake readme and how to 
detailed on vim/nano edits in the files


# Resources
all softwares that we use - paper (chicago or smth) or github (list of links)
Genomescope github(link to github): help me file / how to starter page (link)
