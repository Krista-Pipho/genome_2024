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
# install pipeline
clone git@github.com:Krista-Pipho/genome_2024.git
cd genome_2024
conda create --name assembly_env --file environment.txt 
conda activate assembly_env
# this environment includes all the packages and other software tools, so no other software downloads are required
```

Creating the environment can take a considerable amount of time, expect 10-60 minutes.

<br> 

**Testing the Pipeline**
<br> 

Using example yeast HIFI reads we will go through a test run of the pipeline and its rules (processes).

1. Download the example data from SRA using this command
```
fasterq-dump SRR13577847
mv SRR13577847.fastq SRR13577847.fa
```
2. Run `$ snakemake --dry-run` to test if workflow is properly installed and estimate the amount of needed resources. This `--dry-run` flag evaluates the rules without running the actual commands, and also created a DAG image (`/genome_2024/src/rulegraph.png`) that shows the workflow of all rules.
**INSERT IMG**

    a. If on a cluster, the pipeline DAG image (and also any other files) can be viewed by pulling the file from shell to your local computer via `$ scp netid321@dcc-login.oit.duke.edu:/path/to/genome_2024/src/dag.png /local/path/to/save` on local terminal
5. If no errors, run `$ sbatch launch.sh` while inside the `src` folder. This file is a wrapper to run the Snakemake commands, found in the Snakefile within the src folder.

    a. If on SLURM, run `squeue -u userID` to view the job process.
6. Open the corresponding slurm log to monitor the live process output
<br> 

**Rule Explanations**
<br> 

6. 6 min to run the assembly rule for yeast SRR

# Resources

# References
