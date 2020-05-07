#!/bin/bash
if [ $# -lt 0 ]; then
  echo ""
  echo "Usage: ./SkewC.sh \$basename \$indir \$outdir"
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
bin/SkewC.pl $basename $indir $outdir
