#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use Getopt::Std;
use IO::File;
use File::Temp qw/tempfile/;
use vars qw($opt_s $opt_e $opt_d);
getopts('e:s:d:');
my ($prgname,$prgdir,$prgsuffix)=fileparse($0);
if(scalar(@ARGV)<3){print STDERR "perl SkewC.pl INDIR OUTDIR BASENAME\n";exit(0);}
my $basename=$ARGV[0];
my $indir=$ARGV[1];
my $outdir=$ARGV[2];
my $start=defined($opt_s)?$opt_s:0.05;
my $end=defined($opt_e)?$opt_e:1.00;
my $step=defined($opt_d)?$opt_d:0.05;
my @files=`ls $indir/*.r`;
my ($fh,$tmpfile)=tempfile(DIR=>$outdir,TEMPLATE=>'XXXXXX',SUFFIX=>'.r');
foreach my $file(@files){
	chomp($file);
	open(IN,$file);
	while(<IN>){
		chomp;
		if($_!~/\<\- c\([\d\.\,]+\)/){next;}
		print $fh "${basename}_$_\n";
	}
	close(IN);
}
close($fh);
for(my $alpha=$start;$alpha<$end;$alpha+=$step){
	$alpha=sprintf("%0.2f",$alpha);
	print STDERR "Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename $alpha\n";
	system("Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename $alpha\n");
}
unlink($tmpfile);
open(OUT,">$outdir/$basename/index.html");
print OUT "<html>\n";
print OUT "<head>\n";
print OUT "<title>$basename SkewC</title>\n";
print OUT "<style>\n";
print OUT "h1{text-align:center;}\n";
print OUT "td{text-align:center;}\n";
print OUT "th{text-align:center;}\n";
print OUT "</style>\n";
print OUT "</head>\n";
print OUT "<body>\n";
print OUT "<h1>SkewC: $basename</h1>\n";
print OUT "<center>\n";
print OUT "<table border=1>\n";
my $dir=sprintf("%.2f",$start);
print OUT "<tr><th>FullCoverage</th><th>MeanCoverage</th></tr>\n";
print OUT "<tr><td><a href=\"$dir/FullCoverage.pdf\"><embed src=\"$dir/FullCoverage.pdf\" width=300 height=300></a></td><td><a href=\"$dir/MeanCoverage.pdf\"><embed src=\"$dir/MeanCoverage.pdf\" width=300 height=300></a></td></tr>\n";
print OUT "</table>\n";
print OUT "<table border=1>\n";
print OUT "<tr><th>Alpha</th><th>CLUSTResult</th><th>TypicalcellFullCoverage</th><th>SkewedcellFullCoverage</th><th>Typical</th><th>Skew</th></tr>\n";
for(my $alpha=$start;$alpha<$end;$alpha+=$step){
	my $dir=sprintf("%.2f",$alpha);
	my $typicalFile="$dir/TypicalCellsID.tsv";
	my $skewFile="$dir/SkewedCellsID.tsv";
	my $typicalCount=`wc -l<$outdir/$basename/$typicalFile`;
	my $skewCount=`wc -l<$outdir/$basename/$skewFile`;
	print OUT "<tr><th><b>$dir</b></th>\n";
	print OUT "<td><a href=\"$dir/CLUSTResult.pdf\"><embed src=\"$dir/CLUSTResult.pdf\" width=300 height=300></a></td>\n";
	print OUT "<td><a href=\"$dir/TypicalcellFullCoverage.pdf\"><embed src=\"$dir/TypicalcellFullCoverage.pdf\" width=300 height=300></a></td>\n";
	print OUT "<td><a href=\"$dir/SkewedcellFullCoverage.pdf\"><embed src=\"$dir/SkewedcellFullCoverage.pdf\" width=300 height=300></a></td>\n";
	print OUT "<td><a href=\"$typicalFile\">$typicalCount</a></td>\n";
	print OUT "<td><a href=\"$skewFile\">$skewCount</a></td>\n";
	print OUT "</tr>\n";
}
print OUT "</table>\n";
print OUT "</center>\n";
print OUT "</body>\n";
print OUT "</html>\n";
close(OUT);
