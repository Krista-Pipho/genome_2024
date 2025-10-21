# Genome 2024
### Authors: Krista Pipho, Angelina Huang, Avi Heyman, Daniel Levin, and Shriya Minocha


# Description
This Snakemake pipeline is designed for processing PacBio HiFi sequencing data into de-novo genome assemblies. The provided code includes read contaminatation filtering, data quality assessment, genome assembly, and assembly quality assessment. Besides de-novo genome assembly, it can evaluate existing genome assemblies and generate comparative statistics. An R markdown document is used to atuomatically generate html visualizations of pipeline outputs. The final result is a genome suitable for downstream applications such as comparative genomics, evolutionary studies, and functional analyses. 

In detail, the pipeline accepts PacBio HiFi reads in FASTA or BAM format as **input** and generates the following **outputs**:

* **Contaminant Filtering**: Kraken2 identification of contaminant reads
* **Data Quality**: GenomeScope2 kmer analysis of HiFi reads (PNG)
* **Genome Assembly**: hifiasm assembled genome sequence (FASTA)
* **Indexing**: Indexed assembly for efficient access (FAI)
* **Completeness Assessment**: BUSCO analysis to evaluate genome completeness (TXT, TSV)
* **Quality Evaluation**: QUAST report with key assembly metrics (TXT)
* **Structural Evaluation**: Dotplot visualization of compartive sequence order
* **Telomere Identification**: TIDK visualization of telomeric regions (SVG)
* **Summary of Results**: The workflow colates final outputs in results/{sample}
* **Visualization of Results**: The results/{sample} folders are visualized using assembly_pipeline_summary.Rmd

## Requirements
All users will require an instalation of Pixi, a package management alternative to Conda. Install using the command below. Read about pixi here: https://pixi.sh/dev/

```
curl -fsSL https://pixi.sh/install.sh | sh
```

<br>

## Getting Started

### Step 1: Install the pipeline from github

```
git clone https://github.com/Krista-Pipho/genome_2024.git
cd genome_2024
```

### Step 2: Test the pipeline 

Running your instillation for the first time will automatically set up the environment and docker containers needed for analysis while processing a test dataset. 

The config.yaml file in this github repository is pre-configured to assemble yeast HIFI reads from SRA accession SRR13577847 and compare the de-novo assembly against the saccharomyces 288C refference genome. This will test and demonstrate most componants of the pipeline. Execute this test by running the command below.

```
pixi run snakemake --cores 16
```

If you are using a cluster, such as Duke's DCC, execute a similar command using the slurm script provided. Using the script will make execution faster and avoid the possability of out-of-memory errors. This script tells the cluster how many cores and how much ram to assign to running the pipeline. You can change the resources allocated by editing the header of launch.sh. 

```
sbatch launch.sh
```

The last step in a sucessfull analysis run produces a file named SRR13577847_S288C_assembly_summary.html
This can be viewed in any browser, or on VScode using the Microsoft Live Preview extension. 

### Step 3: Analyze your Data

Use the config.yaml file to specify data you would like analyzed. 

sample: 

First, change the 'sample' line to your dataset. The workflow excepts either raw reads (.fastq) or pre-assembled genomes (.gfa). For SRA datasets, use only the SRA number and the data will be automatically downloaded. For custom or pre-downloaded datasets, use only the prefix for your fastq files (ex for SRR13577847.fastq use SRR13577847 as the sample name). 

compare_assembly:

Many features require an additional assembly for comparasin. This can be either raw reads (.fastq) or a pre-assembled genome (.gfa), and should be entered using only the prefix as above. Two useful ways to use this feature are choosing the closest published genome to compare your de-novo assembly to, or comparing two genomes assembled from the same reads using different settings. 

Optional operations to perform:

Many of the analysees in this workflow are optional, and require certain data or parameter inputs. If both the sample and comparasin genome are pre-assembled, be sure to dissable 'filter_reads'  and 'run_genomescope', as these require un-assembled long read data. Several of the options, if marked true, require corresponsing parameters below. Please read these requirements carefully and use the provided links to choose apropriate values. 

Once your config.yaml is customized, test that it is configured properly using the command below. This should quickly produce green and yellow reports about the workflow. Errors will appear in red. The most common cause of errors is a missmatch between the provided data and the sample names in the config.yaml. If you see only green and yellow text using the above command you can run the actual analysis. Do so using the command below. 

```
pixi run snakemake --cores 16
```

If you are using a cluster, such as Duke's DCC, use the provided slurm script instead.
```
sbatch launch.sh
```

<br> 

**Rule Explanations**
<br> 

Once the pipeline begins running, either open the slurm log or view the terminal output. These following explanations will be based off of the yeast genome

| Rule | Description | Output |
| --- | --- | ---- |
| `kraken` |
| `data_qc` | **Quality Control**: Analyzes k-mers of sequencing reads to estimate genome characteristics  | `SRR13577847_linear_plot.png`: linear *plot* showing genome size estimation and heterozygosity |
| `assembly` | **Assembly**: Assembles the genome via HiFiASM and extracts primary contigs from assembled graph | `SRR13577847.p_ctg.fa`: assembled genome |
| `index` | **Indexing**: Creates an `samtools` index to allow fast access to genome sequences | `SRR13577847.p_ctg.fa.fai`: index for the assembled genome |
| `busco` | **Genome Completeness**: Identifies the percentage of conserved genes in the assembled genome when given the reference genome | `SRR13577847_busco_short_summary.txt`: summary report with genome completeness scores |
| `telo` | **Telomere Detection**: Identifies any telomeric regions in the genome | `tidk_SRR13577847.svg`: visual showing any telomere presence |
| `quast` | **Genome Structural Evaluation**: Measures genome assembly accuracy and structure | `SRR13577847_quast_report.txt`: report with assembly statistics like N50, GC content, and misassemblies |

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

### Using Rstudio to visualize outputs
Installing R studio - https://posit.co/download/rstudio-desktop/  
Introduction to R markdown - https://www.youtube.com/watch?v=tKUufzpoHDE&ab_channel=JalayerAcademy  

### How to edit and move files on command line
You can edit the Snakefile text with any editing program, including vim - https://opensource.com/article/19/3/getting-started-vim  
How to move files from a cluster (like DCC) to another computer - https://oit-rc.pages.oit.duke.edu/rcsupportdocs/storage/transfers/  

### Bioinformatics Software
Contamination filtering - 
Pacbio read qc - https://github.com/tbenavi1/genomescope2.0  
Assembly - https://github.com/chhylp123/hifiasm  
Samtools - https://www.htslib.org/  
Assembly completeness - https://busco.ezlab.org/busco_userguide.html 
Assembly structure - 
Telomere finder - https://github.com/tolkit/telomeric-identifier  
Assembly statistics - https://github.com/ablab/quast  
Repeat finding and masking - https://github.com/Dfam-consortium/RepeatModeler  
Gene annotation - https://github.com/ncbi/egapx  
