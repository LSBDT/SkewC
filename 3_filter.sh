#!/bin/bash
if [ $# -lt 1 ]; then
  echo ""
  echo "Usage: ./4_filter.sh \$filter \$indir \$matchdir \$unmatchdir"
  echo ""
  echo "    \$filter   Filter file (Default=coverage)"
  echo "     \$indir   Input directory (Default=coverage)"
  echo "  \$matchdir   match directory with filter list (Default=match)"
  echo "\$unmatchdir   unmatch directory with filter list (Default=unmatch)"
  echo ""
  exit
fi
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
if [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  moirai2/skewc \
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
  moirai2/skewc \
  perl bin/filter.pl \
  $filter \
  $indir \
  $match \
  $unmatch
else
  echo "Please install udocker or docker"
fi
