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
image=moirai2/skewc
sif=skewc.sif
bam=$1
barcode=$2
outdir=$3
if [ -z "$outdir" ]; then
outdir="input"
fi
mkdir -p $outdir
workdir=`pwd`;
if [ -x "$(command -v singularity)" ]; then
singularity exec \
  --bind $PWD \
  $sif \
  perl bin/split10XbyBarcode.pl \
  -o $outdir \
  $bam \
  $barcode
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  $image \
  perl bin/split10XbyBarcode.pl \
  -o $outdir \
  $bam \
  $barcode
elif [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  $image \
  perl bin/split10XbyBarcode.pl \
  -o $outdir \
  $bam \
  $barcode
else
  echo "Please install udocker or docker"
fi
