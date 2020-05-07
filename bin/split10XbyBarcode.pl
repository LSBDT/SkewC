#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use Getopt::Std;
use IO::File;
use vars qw($opt_l $opt_o $opt_r $opt_t);
getopts('l:o:r:t:');
if(scalar(@ARGV)==0){print STDERR "perl split10XbyBarcode.pl -o OUTDIR BAM BARCODE\n";exit(0);}
my $bam=$ARGV[0];
my $barcode=$ARGV[1];
my $length=(defined($opt_l))?$opt_l:3;
my $outdir=(defined($opt_o))?$opt_o:"split";
my $regexp=(defined($opt_r))?$opt_r:"CB:Z:(\\S+)";
my $tmpdir=(defined($opt_t))?$opt_t:"tmp";
mkdir($outdir);
mkdir($tmpdir);
chmod(0777,$outdir);
chmod(0777,$tmpdir);
print("#1 Reading barcode file...\n");
my $barcodes={};
if($barcode=~/\.gz(ip)?$/){open(IN,"gzip -cd $barcode|");}
else{open(IN,$barcode);}
while(<IN>){chomp;$barcodes->{$_}++;}
close(IN);
print("#2 Reading header lines...\n");
my $basename=basename($bam,".bam");
my @headers=();
open(IN,"samtools view -H $bam|");
while(<IN>){push(@headers,$_);}
close(IN);
print("#3 Filtering barcodes...\n");
my $writers={};
my @splits=();
open(IN,"samtools view $bam|");
while(<IN>){
	my $line=$_;
	my $barcode="others";
	if(/$regexp/){
		if(!exists($barcodes->{$1})){next;}
		$barcode=substr($1,0,$length);
	}else{next;}
	if(!exists($writers->{$barcode})){
		my $split="$tmpdir/$basename.$barcode.sam";
		push(@splits,$split);
		my $writer=IO::File->new(">$split");
		$writers->{$barcode}=$writer;
	}
	my $writer=$writers->{$barcode};
	print $writer $line;
}
close(IN);
print("#4 Splitting by barcodes...\n");
my @bams=();
foreach my $writer(values(%{$writers})){close($writer);}
my $count=1;
my $total=scalar(@splits);
print "Completed 0/$total";
foreach my $split(sort{$a cmp $b}@splits){
	my $writers={};
	my @outputs=();
	open(IN,$split);
	while(<IN>){
		my $barcode="others";
		if(/$regexp/){$barcode=$1;}
		else{next;}
		if(!exists($writers->{$barcode})){
			my $output="$outdir/$basename.$barcode.sam";
			push(@outputs,$output);
			my $writer=IO::File->new(">$output");
			$writers->{$barcode}=$writer;
			foreach my $header(@headers){print $writer $header;}
		}
		my $writer=$writers->{$barcode};
		print $writer $_;
	}
	close(IN);
	foreach my $writer(values(%{$writers})){close($writer);}
	foreach my $output(@outputs){
		my $basename=basename($output,".sam");
		my $bam="$outdir/$basename.bam";
		push(@bams,$bam);
		my $command="samtools view -bSo $bam $output 2>/dev/null";
		system($command);
		unlink($output);
	}
	unlink($split);
	print "\rCompleted $count/$total";
	$count++;
}
rmdir($tmpdir);
print("\n# Done...\n");
