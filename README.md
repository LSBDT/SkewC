# SkewC
Latest version of SkewC method implemented in R SkewC a novel quality-assessment method to identify poor quality single-cells in scRNA-seq experiments.
The method relies on the measure of skewness of the gene coverage of each single cell as a quality measure. This folder contains several R Markdowns and should be run in the same order as listed below:

## Structure
```
hdrgenome/
├── 0_split10XbyBarcode.sh
├── 1_indexBamFiles.sh
├── 2_geneBodyCoverage.sh
├── 3_SkewC.sh
├── bash.sh
├── bin/
│   ├── geneBodyCoverage.pl
│   ├── indexBamFiles.pl
│   ├── SkewC.pl
│   ├── SkewC.r
│   ├── split10XbyBarcode.pl
│   └── workers.pl
├── example/
│   ├── barcodes.tsv.gz
│   └── example.bam
├── LICENSE
├── README.md
├── reference/
│   ├── hg38_Gencode_V28.norRNAtRNA.nochr.bed
│   └── mm10_Gencode_VM18.norRNAtRNA.bed
└── RMarkdown/
    ├── coverage.r - sample data for SkewC Rmarkdown
    ├── bash.sh - Running docker image
    ├── SkewC_Create_Coverage_Matrixes.Rmd
    ├── SkewC_Plot_Gene_Body_Coverage.Rmd
    ├── SkewC_Plot_Typical_Skewed_Coverage.Rmd
    └── SkewC_TrimClustering.Rmd -
```
## System
* Linux
* MacOSX
## Requirement
* *git* - https://git-scm.com
* *docker* (https://www.docker.com) or *udocker* (https://github.com/indigo-dc/udocker)
* If you are installing to your personal computer and have admin authority, install docker.
* Install udocker, if you want to run pipeline in Linux environment where you don't have any admin authority (and can't run docker).
## Install
```
git clone https://github.com/LSBDT/SkewC.git
```
## Pipeline
### 0_split10XbyBarcode.sh
```
0_split10XbyBarcode.sh $bam $barcode $outdir
```
* Arguments:
  * $bam     - BAM file from 10XGenomics analysis
  * $barcode - barcodes.tsv.gz under 10XGenomics outs/filtered_feature_bc_matrix/
  * $outdir  - directory to store split BAM files (default='input')
```
outs/filtered_feature_bc_matrix/
    ├── barcodes.tsv.gz <== this file
    ├── features.tsv.gz
    └── matrix.mtx.gz
```
* This script is for 10XGenomics (https://support.10xgenomics.com/).
* Before doing gene body coverage analysis, there is a need to split BAM files by cells.
* Since 10XGenomics output one BAM file, split step is needed.
* If BAM files are split by cells already, you can skip this step.
* If you don't mind using "input" as directory name, you can omit $outdir argument.
### 1_indexBamFiles.sh
```
1_indexBamFiles.sh $indir
```
* Arguments:
  * $indir - directory where split BAM files are stored (default='input')
* Runs "samtools index" on all BAM files under $indir directory.
* If you want, it's ok to run samtools index command through command line.
```
samtools index BAM
```
### 2_geneBodyCoverage.sh
2_geneBodyCoverage.sh $species $indir $outdir
* Arguments:
  * $species - human 'hg38' or mouse 'mm10' (default='hg38')
  * $indir  - directory where split BAM and index files are stored (default='input')
  * $outdir - directory to store geneBodyCoverage.pl output files (default='coverage')
* If you want to run a command line through command line:
```
perl bin/geneBodyCoverage.pl -o coverage reference/hg38_Gencode_V28.norRNAtRNA.bed input/example.TTTGTCATCTAACGGT-1.bam > coverage/example.TTTGTCATCTAACGGT-1.log
```
* 'geneBodyCoverage.pl' is a perl script to imitate process of RSeQC 'geneBody_coverage.py' (http://rseqc.sourceforge.net/#genebody-coverage-py).
* 'geneBodyCoverage.pl' was written to reduce running time of geneBodyCoverage step by about 10 folds.
* Although same algorithm is used, output from geneBodyCoverage.pl and geneBody_coverage.py differs a bit, but it's negligible.
* 'geneBodyCoverage.pl' will create an index file under reference directory at the first iteration.  From second iteration on, indexed reference file will be used to speed up calculation.   Don't run geneBodyCoverage.pl in parallel (at the same time) when it's creating an index file.
* Reference column of BAM file from 10XGenomics, chromosome are represented without "chr".  For chr1 example, reference column of normal BAM file is written "chr1", but in 10XGenomics, it's written "1" only.
* 'geneBodyCoverage.pl' will automatically detect the difference in reference column and create an index reference file with/without 'chr'.
* If you want to run, original 'geneBody_coverage.py':
```
python geneBody_coverage.py -r reference/hg38_Gencode_V28.norRNAtRNA.bed -i input/example.TTTGTCATCTAACGGT-1.bam  -o coverage > log.txt
```
### 3_SkewC.sh
3_SkewC.sh $basename $basename $indir $outdir
* Arguments:
  * $basename - basename of sample (default='COV')
  * $indir  - a directory where geneBodyCoverage.pl output files are stored (default='coverage')
  * $outdir - a directory to store skewc analysis files with index HTML (default='skewc')
* Run SkewC analysis on all geneBody coverage files under indir.
## R Markdown
1-SkewC_Create_Coverage_Matrixes.Rmd
To run this,
      a.user need to have the coverage file (coverage. r) Which contains the results of the gene body coverage. We provide example coverage. r file.
      b-User will be asked to enter the dataset title. This is will be used as label in the output plots.

2-SkewC_Plot_Gene_Body_Coverage.Rmd
     This script will generate two PDFs

3-SkewC_TrimClustering.Rmd
  User will be asked to supply the Alpha value which should be a value between [0 .. 1]. E.g. for large dataset generated by 10X genomics     start with Alpha = 0.099 and evaluate the result.
  This is script will generate two text file (.tsv), contains the list of Typical and Skewed cells.
   Also it will generate a plot with the clustering result (PDF)

4-SkewC_Plot_Typical_Skewed_Coverage.Rmd
  This R Markdown will plot the gene body coverage of the Typical and Skewed cells.
