#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use FileHandle;
use Getopt::Std;
use vars qw($opt_n $opt_o);
getopts('n:o:');
my $file=$ARGV[0];
my $outdir=defined($opt_o)?$opt_o:".";
mkdir($outdir);
my $number=(defined($opt_n))?$opt_n:3;
open(IN,$file);
my $totals={};
my $size=0;
while(<IN>){
	chomp;
	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	my @tokens=split(/,/,$blockSizes);
	my $total=0;
	foreach my $token(@tokens){$total+=$token;}
	$totals->{$total}++;
	$size++;
}
close(IN);
print STDERR "Total gene size: $size\n";
my @lengths=sort{$a<=>$b}keys(%{$totals});
my $minLength=$lengths[0];
my $maxLength=$lengths[scalar(@lengths)-1];
print STDERR "Min gene length: $minLength\n";
print STDERR "Max gene length: $maxLength\n";
print STDERR "\n";
my @numbers=();
for(my $i=0;$i<$number;$i++){push(@numbers,int(($i+1)*$size/$number));}
my $count=0;
my $index=0;
my @thresholds=();
foreach my $length(@lengths){
	$count+=$totals->{$length};
	if(!defined($thresholds[$index])&&$count>$numbers[$index]){$thresholds[$index]=$length;$index++;}
}
$thresholds[$number-1]=$maxLength;
my $basename=basename($file,".bed");
my @writers=();
my @counts=();
for(my $i=0;$i<$number;$i++){push(@writers,IO::File->new(">$outdir/$basename.$i.bed"));}
open(IN,$file);
while(<IN>){
	chomp;
	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	my @tokens=split(/,/,$blockSizes);
	my $total=0;
	foreach my $token(@tokens){$total+=$token;}
	for(my $i=0;$i<$number;$i++){
		if($total<=$thresholds[$i]||$i==$number){
			my $writer=$writers[$i];
			print $writer "$_\t$total\n";
			$counts[$i]++;
			last;
		}
	}
}
close(IN);
foreach my $writer(@writers){close($writer);}
print STDERR "index\tlengths\tcount\n";
for(my $i=0;$i<$number;$i++){
	if($i==0){print STDERR $i."\t$minLength-".$thresholds[$i]."\t".$counts[$i]."\n";}
	elsif($i==$number-1){print STDERR $i."\t".($thresholds[$i-1]+1)."-$maxLength\t".$counts[$i]."\n";}
	else{print STDERR $i."\t".($thresholds[$i-1]+1)."-".$thresholds[$i]."\t".$counts[$i]."\n";}
}