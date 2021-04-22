#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./2_SkewC.sh \$prjname \$indir \$outdir \$alpha"
  echo ""
  echo " \$prjname   name of the project (Default=COV)"
  echo "   \$indir   directory where coverage files are stored (Default=coverage)"
  echo "  \$outdir   directory where results files will be output (Default=skewc)"
  echo "  \$alpha    alpha value to be used for computation of tclust (Default=auto)"
  echo ""
  exit
fi
image=moirai2/skewc
sif=skewc.sif
basename=$1;shift
indir=$1;shift
outdir=$1;shift
alpha=$@
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
if [ -x "$(command -v singularity)" ]; then
singularity exec \
  --bind $PWD
  $sif \
  perl bin/SkewC.pl \
  $basename \
  $indir \
  $outdir \
  $alpha
elif [ -x "$(command -v docker)" ]; then
docker run \
  --memory 2G \
  -it \
  --rm \
  -v $workdir:/root/work \
  --workdir /root/work \
  $image \
  perl bin/SkewC.pl \
  $basename \
  $indir \
  $outdir \
  $alpha
elif [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:/root/work \
  --workdir=/root/work \
  $image \
  perl bin/SkewC.pl \
  $basename \
  $indir \
  $outdir \
  $alpha
else
  echo "Please install udocker or docker"
fi
