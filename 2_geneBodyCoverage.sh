#!/bin/bash
if [ $# -lt 1 ]; then
  echo ""
  echo "Usage: ./geneBodyCoverage.sh \$num \$indir \$outdir \$species"
  echo ""
  echo "  \$num      number of processes to run (Default=1)"
  echo "  \$indir    directory where BAM files and BAI files are stored (Default=input)"
  echo "  \$outdir   directory where coverage files will be output (Default=coverage)"
  echo "  \$species  mm10 [mouse] or hg38 [human] (Default=hg38)"
  echo ""
  exit
fi
number=$1
indir=$2
outdir=$3
reference=$4
if [ -z "$number" ]; then
number=1
fi
if [ -z "$indir" ]; then
indir="input"
fi
if [ -z "$outdir" ]; then
outdir="coverage"
fi
if [ "$reference" = "hg38" ]; then
  reference="reference/hg38_Gencode_V28.norRNAtRNA.bed"
elif [ "$reference" = "mm10" ]; then
  reference="reference/mm10_Gencode_VM18.norRNAtRNA.bed"
else
  reference="reference/hg38_Gencode_V28.norRNAtRNA.bed"
fi

for ((i=0; i < $number; i++)); do
 perl bin/workers.pl -r $indir $outdir 'bash bin/geneBodyCoverage.sh $in.bam $out.geneBodyCoverage.r '$reference &
done
