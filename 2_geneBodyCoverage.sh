#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./2_geneBodyCoverage.sh \$species \$indir \$outdir"
  echo ""
  echo "  \$species  mm10 [mouse] or hg38 [human]"
  echo "  \$indir    directory where BAM files and BAI files are stored (Default=input)"
  echo "  \$outdir   directory where coverage files will be output (Default=coverage)"
  echo ""
  exit
fi
reference=$1
indir=$2
outdir=$3
if [ -z "$indir" ]; then
indir="input"
fi
if [ -z "$outdir" ]; then
outdir="coverage"
fi
mkdir -p $outdir
if [ "$reference" = "hg38" ]; then
  reference="reference/hg38_Gencode_V28.norRNAtRNA.bed"
elif [ "$reference" = "mm10" ]; then
  reference="reference/mm10_Gencode_VM18.norRNAtRNA.bed"
elif [[ "$reference" == *.bed ]]; then
  :
else
  reference="reference/hg38_Gencode_V28.norRNAtRNA.bed"
fi
echo $reference
workdir=`pwd`;
if [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  moirai2/skewc \
  perl bin/workers.pl \
  -r \
  $indir \
  $outdir \
  "perl bin/geneBodyCoverage.pl -o $outdir $reference \$in.bam > \$out.log"
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  moirai2/skewc \
  perl bin/workers.pl \
  -r \
  $indir \
  $outdir \
  "perl bin/geneBodyCoverage.pl -o $outdir $reference \$in.bam > \$out.log"
else
  echo "Please install udocker or docker"
fi
rmdir workers
