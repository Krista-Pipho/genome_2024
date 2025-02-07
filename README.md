# Genome 2024
### Authors: Krista Pipho, Avi Heyman, Angelina Huang, Daniel Levin, and Shriya Minocha

# Description
This Snakemake pipeline is designed for processing PacBio HiFi sequencing data, performing genome assembly, quality assessment, and annotation. Besides de-novo genome assembly, it can evaluate existing genome assemblies and generate comparative statistics too. The pipeline provides a comprehensive summary that includes quality control via BUSCO and quast, genome annotations of known subsequences, and telomere occurences that, in total, assess the accuracy and completeness of the inputted long-read genome. The final result is a fully processed and annotated genome, suitable for downstream applications such as comparative genomics, evolutionary studies, and functional analyses. 

In detail, the pipeline accepts PacBio HiFi reads in FASTA or BAM format as **input** and generates the following **outputs**:

* **Genome Assembly**: Assembled genome sequence (FASTA)
* **Indexing**: Indexed assembly for efficient access (FAI)
* **Completeness Assessment**: BUSCO analysis to evaluate genome completeness (TXT, TSV)
* **Quality Evaluation**: QUAST report with key assembly metrics (TXT)
* **Telomere Identification**: Visualization of telomeric regions (SVG)
* **Masked Assembly**: Repetitive element-masked genome (FASTA)
* **Functional Annotations**: Gene (GFF) and noncoding RNA (GFF) annotations


## Requirements
* Any version of conda ie [miniconda](https://docs.anaconda.com/miniconda/install/) or bioconda

### Duke Security: SSH key generation and DCC -> Github connection
  
1. Login to DCC using `$ ssh netid321@dcc-login.oit.duke.edu`
2. Generate SSH key using `$ ssh-keygen` and select default file location
3. Go to your Github profile and select "SSH Keys" from left sidebar 
4. "Add SSH Key" and enter the id_rsa.pub file contents into the "Key" field, and "Add Key"
<br>

## Getting Started
```
# install pipeline
git clone https://github.com/Krista-Pipho/genome_2024.git
cd genome_2024/src
conda create --name myenv --file assembly_pipeline_environment.txt # change myenv to a functional name
conda activate myenv
# this environment includes all the packages and other software tools, so no other software downloads are required
```

<br> 

**Simple Use Case**
<br> 

Using the sample yeast genome given found in `/genome_2024/raw_data/yeast.fasta`, we will go through a sample run of the pipeline and its rules (processes).

3. Run `$ snakemake --dry-run` to test if workflow is properly installed and estimate the amount of needed resources. This `--dry-run` flag evaluates the rules without running the actual commands, and also created a DAG image (`/genome_2024/src/rulegraph.png`) that shows the workflow of all rules.
**INSERT IMG**

    a. If on a cluster, the pipeline DAG image (and also any other files) can be viewed by pulling the file from shell to your local computer via `$ scp netid321@dcc-login.oit.duke.edu:/path/to/genome_2024/src/dag.png /local/path/to/save` on local terminal
4. If no errors, run `$ sbatch launch.sh` while inside the `src` folder. This file is a wrapper to run the Snakemake commands, found in the Snakefile within the src folder.

    a. If on SLURM, run `squeue -u userID` to view the job process.
5. Open the corresponding slurm log to monitor the live process output
<br> 

**Rule Explanations**
<br> 

6. 6 min to run the assembly rule for yeast SRR

# Resources

# References