#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./indexBamFiles.sh \$indir"
  echo ""
  echo "  \$indir  Directory where bam files are stored (Default=input)"
  echo ""
  exit
fi
indir=$1
if [ -z "$indir" ]; then
indir="input"
fi
workdir=`pwd`;
if [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  moirai2/skewc \
  perl bin/indexBamFiles.pl \
  $indir \
  > /dev/null 2>&1
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  moirai2/skewc \
  perl bin/indexBamFiles.pl \
  $indir \
  > /dev/null 2>&1
else
  echo "Please install udocker or docker"
fi
