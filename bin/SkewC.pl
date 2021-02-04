#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use Getopt::Std;
use IO::File;
use File::Temp qw/tempfile/;
use vars qw($opt_s $opt_e $opt_d);
getopts('e:s:d:');
my ($prgname,$prgdir,$prgsuffix)=fileparse($0);
if(scalar(@ARGV)<3){print STDERR "perl SkewC.pl BASENAME INDIR OUTDIR ALPHA\n";exit(0);}
my @alphaValues=@ARGV;
my $basename=shift(@alphaValues);
my $indir=shift(@alphaValues);
my $outdir=shift(@alphaValues);
my $start=defined($opt_s)?$opt_s:0.05;
my $end=defined($opt_e)?$opt_e:1.00;
my $step=defined($opt_d)?$opt_d:0.05;
my @files=();
if(-d $indir){@files=`ls $indir/*.r`;}
else{push(@files,$indir);}
mkdir($outdir);
my ($fh,$tmpfile)=tempfile(DIR=>$outdir,TEMPLATE=>'XXXXXX',SUFFIX=>'.r');
foreach my $file(@files){
	chomp($file);
	open(IN,$file);
	while(<IN>){
		chomp;
		if(/^(\S+)\s+\<\- c\([\d\.\,]+\)/){
			my $id=$1;
			print $fh "${basename}$_\n";
		}
	}
	close(IN);
}
close($fh);
if(scalar(@alphaValues)==0){
	print STDERR "Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename\n";
	system("Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename\n");
}else{
	foreach my $alpha(@alphaValues){
		print STDERR "Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename $alpha\n";
		system("Rscript --vanilla ${prgdir}SkewC.r $tmpfile $outdir $basename $alpha\n");
	}
}
unlink($tmpfile);
my @alphaValues=listAlphaDirs("$outdir/$basename");
if(scalar(@alphaValues)==0){print STDERR "No alpha value computation found\n";exit();}
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
my $dir=$alphaValues[0];
print OUT "<tr><th>FullCoverage</th><th>MeanCoverage</th></tr>\n";
print OUT "<tr><td><a href=\"$dir/FullCoverage.pdf\"><embed src=\"$dir/FullCoverage.pdf\" width=300 height=300></a></td><td><a href=\"$dir/MeanCoverage.pdf\"><embed src=\"$dir/MeanCoverage.pdf\" width=300 height=300></a></td></tr>\n";
print OUT "</table>\n";
print OUT "<table border=1>\n";
print OUT "<tr><th>Alpha</th><th>CLUSTResult</th><th>TypicalcellFullCoverage</th><th>SkewedcellFullCoverage</th><th>Typical</th><th>Skew</th></tr>\n";
foreach my $dir(@alphaValues){
	my $typicalFile="$dir/TypicalCellsID.tsv";
	my $skewFile="$dir/SkewedCellsID.tsv";
	my $typicalCount=`wc -l<$outdir/$basename/$typicalFile`;
	my $skewCount=`wc -l<$outdir/$basename/$skewFile`;
	my $curveFile="$dir/ctlcurves.pdf";
	if(-e "$outdir/$basename/$curveFile"){
		print OUT "<tr><th><font color='red'><big><b>$dir<br><a href=\"$curveFile\"><embed src=\"$curveFile\" width=150 height=150></a><br>auto</b></big></font></th>\n";
	}else{
		print OUT "<tr><th><b>$dir</b></th>\n";
	}
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
############################## listAlphaDirs ##############################
sub listAlphaDirs{
	my $directory=shift();
	opendir(DIR,$directory);
	my @array=();
	foreach my $file(readdir(DIR)){
		if($file=~/^\./){next;}
		my $path="$directory/$file";
		if(-d $path){push(@array,$file);}
	}
	return sort {$a<=>$b} @array;
}
############################## printTable ##############################
sub printTable{
	my @out=@_;
	my $return_type=$out[0];
	if(lc($return_type) eq "print"){$return_type=0;shift(@out);}
	elsif(lc($return_type) eq "array"){$return_type=1;shift(@out);}
	elsif(lc($return_type) eq "stderr"){$return_type=2;shift(@out);}
	else{$return_type= 2;}
	printTableSub($return_type,"",@out);
}
sub printTableSub{
	my @out=@_;
	my $return_type=shift(@out);
	my $string=shift(@out);
	my @output=();
	for(@out){
		if(ref( $_ ) eq "ARRAY"){
			my @array=@{$_};
			my $size=scalar(@array);
			if($size==0){
				if($return_type==0){print $string."[]\n";}
				elsif($return_type==1){push(@output,$string."[]");}
				elsif($return_type==2){print STDERR $string."[]\n";}
			}else{
				for(my $i=0;$i<$size;$i++){push(@output,printTableSub($return_type,$string."[$i]=>\t",$array[$i]));}
			}
		} elsif(ref($_)eq"HASH"){
			my %hash=%{$_};
			my @keys=sort{$a cmp $b}keys(%hash);
			my $size=scalar(@keys);
			if($size==0){
				if($return_type==0){print $string."{}\n";}
				elsif($return_type==1){push( @output,$string."{}");}
				elsif($return_type==2){print STDERR $string."{}\n";}
			}else{
				foreach my $key(@keys){push(@output,printTableSub($return_type,$string."{$key}=>\t",$hash{$key}));}
			}
		}elsif($return_type==0){print "$string\"$_\"\n";}
		elsif($return_type==1){push( @output,"$string\"$_\"");}
		elsif($return_type==2){print STDERR "$string\"$_\"\n";}
	}
	return wantarray?@output:$output[0];
}
