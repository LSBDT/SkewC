#!/bin/sh
outdir=$1
sample=$2
if [ -z "$outdir" ]; then
outdir="TestData"
fi
mkdir -p $outdir
if [ -z "$sample" ]; then
sample="neurons900"
fi
if [ "$sample" = "neurons900" ]; then
wget -P $outdir https://single-cell.riken.jp/suppl/skewc/neurons900/barcodes.tsv
wget -P $outdir https://single-cell.riken.jp/suppl/skewc/neurons900/neurons_900.bam
fi