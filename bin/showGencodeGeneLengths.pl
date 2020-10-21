#!/usr/bin/perl
use strict 'vars';
use File::Basename;
my $file=$ARGV[0];
open(IN,$file);
my $lengths={};
my $size=0;
while(<IN>){
	chomp;
	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	my @tokens=split(/,/,$blockSizes);
	my $total=0;
	foreach my $token(@tokens){$total+=$token;}
	$lengths->{$id}=$total;
	$size++;
}
close(IN);
my @ids=sort{$lengths->{$a}<=>$lengths->{$b}}keys(%{$lengths});
foreach my $id(@ids){print $id."\t".$lengths->{$id}."\n";}