#!/bin/bash
if [ $# -lt 2 ]; then
  echo ""
  echo "Usage: ./0_split10XbyBarcode.sh \$bam \$barcode \$outdir"
  echo ""
  echo "  \$bam      BAM file of 10XGenomics"
  echo "  \$barcode  barcode.tsv file of 10XGenomics"
  echo "  \$outdir   Directory where splitted bam files will be output (Default=input)"
  echo ""
  exit
fi
bam=$1
barcode=$2
outdir=$3
if [ -z "$outdir" ]; then
outdir="input"
fi
mkdir -p $outdir
workdir=`pwd`;
if [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  moirai2/skewc \
  perl bin/split10XbyBarcode.pl \
  -o $outdir \
  $bam \
  $barcode \
  > /dev/null 2>&1
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  moirai2/skewc \
  perl bin/split10XbyBarcode.pl \
  -o $outdir \
  $bam \
  $barcode \
  > /dev/null 2>&1
else
  echo "Please install udocker or docker"
fi
