#!/usr/bin/perl
use strict 'vars';
use File::Basename;
my $file=$ARGV[0];
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
	print "$_\t$total\n";
	$size++;
}
close(IN);
my @lengths=sort{$a<=>$b}keys(%{$totals});
my $lowerCount=int($size/3);
my $upperCount=int(2*$size/3);
my $lowerThreshold;
my $upperThreshold;
my $index=0;
foreach my $length(@lengths){
	$index+=$totals->{$length};
	if(!defined($lowerThreshold)&&$index>$lowerCount){$lowerThreshold="$length";}
	if(!defined($upperThreshold)&&$index>$upperCount){$upperThreshold="$length";}
}
#foreach my $length(@lengths){print STDERR "$length\t".$totals->{$length}."\n";}
print STDERR "Total of $size genes\n";
print STDERR "Reaches $lowerCount genes at exon length $lowerThreshold\n";
print STDERR "Reaches $upperCount genes at exon length $upperThreshold\n";
my $basename=basename($file,".bed");
open(OUT1,">$basename.1.bed");
open(OUT2,">$basename.2.bed");
open(OUT3,">$basename.3.bed");
open(IN,$file);
while(<IN>){
	chomp;
	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	my @tokens=split(/,/,$blockSizes);
	my $total=0;
	foreach my $token(@tokens){$total+=$token;}
	if($total<=$lowerThreshold){print OUT1 "$_\t$total\n";}
	elsif($total<=$upperThreshold){print OUT2 "$_\t$total\n";}
	else{print OUT3 "$_\t$total\n";}
}
close(IN);
close(OUT1);
close(OUT2);
close(OUT3);