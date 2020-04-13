#!/usr/bin/perl
use strict;
my $input=$ARGV[0];
my $output=$ARGV[1];
open(OUT,"|samtools view -bS '-' > $output");
open(IN,"samtools view -H $input|");
while(<IN>){print OUT $_;}
close(IN);
#0x1 template having multiple segments in sequencing
#0x2 each segment properly aligned according to the aligner
#0x4 segment unmapped
#0x8 next segment in the template unmapped
#0x10 SEQ being reverse complemented
#0x20 SEQ of the next segment in the template being reverse complemented
#0x40 the first segment in the template
#0x80 the last segment in the template
#0x100 secondary alignment
#0x200 not passing filters, such as platform/vendor quality controls
#0x400 PCR or optical duplicate
#0x800 supplementary alignment
open(IN,"samtools view -F 0x704 $input|");
while(<IN>){
	my ($qname,$flag,$rname,$pos,$mapq,$cigar,$rnext,$pnext,$tlen,$seq,$qual)=split(/\t/);
	if($cigar=~/D/){next;}
	if($mapq<4){next;}
	print OUT $_;
}
close(IN);
close(OUT);
