#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./3_SkewC.sh \$basename \$indir \$outdir"
  echo ""
  echo "  \$indir    directory where coverage files are stored (Default=coverage)"
  echo "  \$outdir   directory where results files will be output (Default=skewc)"
  echo ""
  exit
fi
basename=$1
indir=$2
outdir=$3
if [ -z "$basename" ]; then
basename="COV"
fi
if [ -z "$indir" ]; then
indir="coverage"
fi
if [ -z "$outdir" ]; then
outdir="skewc"
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
  perl bin/SkewC.pl \
  $basename \
  $indir \
  $outdir
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  moirai2/skewc \
  perl bin/SkewC.pl \
  $basename \
  $indir \
  $outdir
else
  echo "Please install udocker or docker"
fi
