# Genome 2024
### Authors: Krista Pipho, Angelina Huang, Avi Heyman, Daniel Levin, and Shriya Minocha


# Description
This Snakemake pipeline is designed for processing PacBio HiFi sequencing data into de-novo genome assemblies. The provided code includes data quality assessment, genome assembly, assembly quality assessment, and gene annotation. Besides de-novo genome assembly, it can evaluate existing genome assemblies and generate comparative statistics. An R markdown document has been provided for visualization of pipeline outputs. The final result is a processed and annotated genome, suitable for downstream applications such as comparative genomics, evolutionary studies, and functional analyses. 

In detail, the pipeline accepts PacBio HiFi reads in FASTA or BAM format as **input** and generates the following **outputs**:

* **Data Quality**: GenomeScope2 kmer analysis of HiFi reads (PNG)
* **Genome Assembly**: hifiasm assembled genome sequence (FASTA)
* **Indexing**: Indexed assembly for efficient access (FAI)
* **Completeness Assessment**: BUSCO analysis to evaluate genome completeness (TXT, TSV)
* **Quality Evaluation**: QUAST report with key assembly metrics (TXT)
* **Telomere Identification**: TIDK visualization of telomeric regions (SVG)
* **Summary of Results**: The clean_results rule creates a folder in results/{sample}
* **Visualization of Results**: The results/{sample} folder can visualized using assembly_pipeline_summary.Rmd

## Requirements
* Any version of conda ie [miniconda](https://docs.anaconda.com/miniconda/install/) or bioconda
* DCC users should follow installation instructions here: https://oit-rc.pages.oit.duke.edu/rcsupportdocs/software/user/

<br>

## Getting Started

### Step 1: Install the pipeline from github

```
git clone https://github.com/Krista-Pipho/genome_2024.git
cd genome_2024
```

### Step 2: Create a conda environment 

By default the environment is called assembly_env. This includes all the packages and software required to run the pipeline. No other software downloads are required.   

```
conda env create -f environment.txt
```

Creating the environment can take a considerable amount of time, expect 10-120 minutes. 
If creating the environment is sucessful, you should see the text below as output:

```
# To activate this environment, use
# conda activate assembly_env
# To deactivate an active environment, use
# conda deactivate
```
If you do not see the above message, re-try creating the environment.

DCC users, you can make this go faster and avoid 'killed' errors by running this using the command below. 
For other slurm cluster users, remove the partition specification in build_environment.sh

```
sbatch build_environment.sh
```

### Step 3: Activate the conda environment

The environment must be activated every time the pipeline is used, not just for installation. 

```
conda activate assembly_env
```

### Step 4: Test the pipeline

Here we provide a small test dataset to quickly test that your pipeline installation is functioning. Please note that this pipeline was designed and optimized using data from heliconius butterflies, not yeast. 
Using example yeast HIFI reads we will go through a test run of the pipeline and its parts.

Download the example data from SRA accession SRR13577847

```
fasterq-dump SRR13577847
mv SRR13577847.fastq SRR13577847.fa
``` 

Before running the pipeline, test if it is working properly. The command below should produce green and yellow reports about the pipeline. Errors will appear in red. The most common cause of errors is a missmatch between the provided data and the sample names in the Snakefile. The Snakefile as-downloaded should match the sample data but needs to be changed in order to work with your own data. See the customization section below. 

```
snakemake --dry-run
```

If you see only green and yellow text using the above command you can run the actual analysis. 

If you are not using a cluster, execute the simple command below. 
```
snakemake 
```

DCC users, use the provided slurm launch script. This script tells the cluster how many cores and how much ram to assign to running the pipeline. You can change the resources used by editing the header of launch.sh. 
For other slurm cluster users, remove the partition specification in build_environment.sh

```
sbatch launch.sh
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

The basic version of customizing the pipeline to work on your own data involves editing the top few lines of the 'Snakefile'. The table below shows the existing code and discusses how to make changes. 

| Code | Function |
| --- | --- | 
| all_samples=\["SRR13577847"\] | The brackets contain a list of 'samples' to analyze. Put one or more sample names in quotes and seperated by commas. Do not include file extensions like .fa |
| cores="10" | Specifies a number of cores to use in processes where an explicet number must be given. On DCC values above 64 can cause errors. On your local machiene avoid using more that 75% of the avaliable cores. |
| busco_lineage="lepidoptera" | This must be changed to match your data. Find the avaliable options here https://busco.ezlab.org/list_of_lineages.html | 


If your data source gave you a .bam file of HiFi reads, convert it to the correct input for the pipeline using the code below

```
samtools fasta sample.bam > sample.fa
```

You can run the summary functions of the pipeline on existing assemblies by creating a folder with the desired sample name within the analysis folder. Place the genome fasta at this file location: analysis/{sample}/{sample}.p_ctg.fa  
Then change the sample line within the Snakefile to:
```all_samples=["sample"]```

## Viewing Results

Raw results are present in the relevant subfolders of the analysis folder. Curated results relevant to this workflow's visualization code can be found within the results folder. 
  
The specific visualization RMD included in this workflow is designed to assess how two assemblies compare to eachother. This can productively be used to compare a new assembly to the previous standard in the field, to compare assemblies from different individuals or species, or to compare assembly conditions which you have customized by editing the HiFiasm command within the assembly.sh script. To use the visualization RMD, copy the entire sample folder from results on DCC into a working directory on your local machiene. This working directory should also contain the assembly_pipeline_summary.Rmd file from this repository. The only change required should be updating sample names at the top of assembly_pipeline_summary.Rmd to macth the names of your results folders.  


# Resources

### About Snakemake Pipelines
What is snakemake - https://academic.oup.com/bioinformatics/article/28/19/2520/290322  
How workflows are coded - https://snakemake.readthedocs.io/en/stable/tutorial/basics.html  

### How to use Rstudio to visualize outputs
Installing R studio - https://posit.co/download/rstudio-desktop/  
Introduction to R markdown - https://www.youtube.com/watch?v=tKUufzpoHDE&ab_channel=JalayerAcademy  

### How to edit and move files on command line
You can edit the Snakefile text with any editing program, including vim - https://opensource.com/article/19/3/getting-started-vim  
How to move files from a cluster (like DCC) to another computer - https://oit-rc.pages.oit.duke.edu/rcsupportdocs/storage/transfers/  

### Bioinformatics Software
Pacbio read qc - https://github.com/tbenavi1/genomescope2.0  
Assembly - https://github.com/chhylp123/hifiasm  
Samtools - https://www.htslib.org/  
Assembly completeness - https://busco.ezlab.org/busco_userguide.html  
Telomere finder - https://github.com/tolkit/telomeric-identifier  
Assembly statistics - https://github.com/ablab/quast  
Repeat finding and masking - https://github.com/Dfam-consortium/RepeatModeler  
Gene annotation - https://github.com/ncbi/egapx  
