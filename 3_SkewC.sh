#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./3_SkewC.sh \$prjname \$indir \$outdir \$filter"
  echo ""
  echo " \$prjname   name of the project (Default=COV)"
  echo "   \$indir   directory where coverage files are stored (Default=coverage)"
  echo "  \$outdir   directory where results files will be output (Default=skewc)"
  echo "  \$filter   a list of cellIDs to be removed (Default=none)"
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
  --memory 2G \
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
