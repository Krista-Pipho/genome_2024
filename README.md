# Sex Chromosome Identification Pipeline
### Authors: Krista Pipho, Angelina Huang

# Description
Identification of the sex chromosome pipeline, which we used W chromosome in Heliconius butterflies.

1. hifiManual.sh and hifiAssembly.sh - HiFi assembly, one is manual input terminal command, other is more automatic

2. busco.sh - singularity docker to access buso files and commands

3. genomeCov.sh - plotCoverage for each of 4 leg samples

4. kmerAnalysis.sh - jellyfish makes a .histo (dont run again after) -> genomescope takes .histo and does kmer analysis

5. mummerBlash.sh - mummer our masked fasta

6. ncbiBlast.sh - blasting masked genome ORFs against the reference dbs created above that were pulled from literature

7. ORF.sh - finds orf using masked fasta from hifi

8. readAlignmentAuto.sh and readAlignment.sh - aligning de novo HMR genome against the gynandromorph data

9. scaffoldCov.sh - plotcoverage for each scaffold

10. testGenomeScope.sh - genomescope