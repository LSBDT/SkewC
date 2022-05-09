#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./util_sample.sh \$outdir \$sample"
  echo ""
  echo "    \$outdir   Output directory (Default=TestData)"
  echo "    \$sample   Sample libarary to download (Default=neurons900)"
  echo ""
  exit
fi
image=moirai2/skewc
sif=skewc.sif
outdir=$1
sample=$2
workdir=`pwd`;
if [ -x "$(command -v singularity)" ]; then
singularity exec \
  --bind $PWD \
  $sif \
  bash bin/download_sample.sh \
  $outdir \
  $sample
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  $image \
  bash bin/download_sample.sh \
  $outdir \
  $sample
elif [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  $image \
  bash bin/download_sample.sh \
  $outdir \
  $sample
else
  echo "Please install docker, singularity, or udocker"
fi
