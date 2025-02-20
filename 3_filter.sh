#!/bin/bash
if [ $# -lt 1 ]; then
  echo ""
  echo "Usage: ./util_filter.sh \$filter \$indir \$matchdir \$unmatchdir"
  echo ""
  echo "    \$filter   Filter file (Default=coverage)"
  echo "     \$indir   Input directory (Default=coverage)"
  echo "  \$matchdir   match directory with filter list (Default=match)"
  echo "\$unmatchdir   unmatch directory with filter list (Default=unmatch)"
  echo ""
  exit
fi
image=moirai2/skewc
sif=skewc.sif
filter=$1
indir=$2
match=$3
unmatch=$4
if [ -z "$indir" ]; then
indir="coverage"
fi
if [ -z "$match" ]; then
match="match"
fi
if [ -z "$unmatch" ]; then
unmatch="unmatch"
fi
mkdir -p $match
mkdir -p $unmatch
workdir=`pwd`;
if [ -x "$(command -v singularity)" ]; then
singularity exec \
  --bind $PWD \
  $sif \
  perl bin/filter.pl \
  $filter \
  $indir \
  $match \
  $unmatch
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  $image \
  perl bin/filter.pl \
  $filter \
  $indir \
  $match \
  $unmatch
elif [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  $image \
  perl bin/filter.pl \
  $filter \
  $indir \
  $match \
  $unmatch
else
  echo "Please install docker, singularity, or udocker"
fi
