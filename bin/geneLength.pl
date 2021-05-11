#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use FileHandle;
my $file=$ARGV[0];
open(IN,$file);
my $size=0;
my $totals={};
while(<IN>){
	chomp;
	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	my @tokens=split(/,/,$blockSizes);
	my $total=0;
	foreach my $token(@tokens){$total+=$token;}
	$totals->{$total}++;
	$size++;
}
print "size=$size\n";
print "length\tcount\n";
my @lengths=sort{$a<=>$b}keys(%{$totals});
foreach my $length(@lengths){print $length."\t".$totals->{$length}."\n";}
close(IN);