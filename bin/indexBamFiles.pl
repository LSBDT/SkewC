#!/usr/bin/perl
use strict 'vars';
use File::Basename;
use Getopt::Std;
use IO::File;
if(scalar(@ARGV)==0){print STDERR "perl indexBamFiles.pl BAMDIR\n";exit(0);}
my $bamdir=$ARGV[0];
my @files=`ls $bamdir/*.bam`;
my $count=1;
my $total=scalar(@files);
print "Completed 0/$total";
foreach my $file(@files){
	chomp($file);
	system("samtools index $file");
	print "\rCompleted $count/$total";
	$count++;
}
print("\n# Done...\n");
