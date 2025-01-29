# Genome 2024
### Authors: Krista Pipho, Avi Heyman, Angie Huang, Daniel Levin, Shriya Minocha

# Description
This Snakemake pipeline is designed for processing PacBio HiFi sequencing data, assembling a genome, evaluating its quality, and annotating it. The workflow first simultaneuoslyn runs genome assembly and quality control of the sequencing reads. Then using the completed assembly, the pipeline performs indexing, telomere identification, masking, and functional annotations of both coding and noncoding regions. It also evaluates the de-novo assembly based on metrics like completeness, contiguity, and redundancy. The final output consists of an annotated high-quality genome assembly, ready for further biological analysis.

## Requirements
1. Any version of conda ie miniconda or bioconda
#### Security: SSH key generation and DCC -> Github connection  
1. Login to DCC using `r ssh netid321@dcc-login.oit.duke.edu`
2. Generate SSH key using `r ssh-keygen` and select default file location
3. Go to your Github profile and select "SSH Keys" from left sidebar 
4. "Add SSH Key" and enter the id_rsa.pub file contents into the "Key" field, and "Add Key"

<br>
## Getting Started
### Downloading Pipeline
1. The pipeline is accessible in this [Github repo](https://github.com/Krista-Pipho/genome_2024). Everything else you will need is included in the cloned folder.
2. To create the environment the pipeline will utilize, within /genome_2024/src, run `r conda create --name myenv --file assembly_pipeline_environment.txt`

#### Simple Use Case
3. Run `r snakemake --dry-run` to check if workflow is properly defined and estimate amount of needed resources
    a. The pipeline DAG image (and also any other files) can be pulled from shell to your local computer via `r scp netid321@dcc-login.oit.duke.edu:/path/to/genome_2024/src/dag.png /local/path/to/save` on local terminal
4. If no errors, run `r sbatch launch.sh` 
5. Open the corresponding slurm log to monitor the live process output
**Rule Explanations**
6. 

# Resources

# References