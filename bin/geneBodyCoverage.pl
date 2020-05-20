#!/usr/bin/perl
use File::Temp qw/tempfile/;
use File::Basename;
use POSIX qw(floor ceil);
use DirHandle;
use strict;
use Getopt::Std;
use Time::localtime;
use vars qw($opt_o);
getopts('o:');
############################## help ##############################
if(scalar(@ARGV)<2){
	print STDERR "\n";
	print STDERR "PROGRAM:\n";
	print STDERR "  - Does gene body coverage calculation using algorithm from RSeQC geneBody_coverage.py\n";
	print STDERR "  - RSeQC website: http://rseqc.sourceforge.net)\n";
	print STDERR "  \n";
	print STDERR "USAGE: geneBodyCoverage.pl -o \$outdir \$reference \$input > \$skewness\n";
	print STDERR "  \$input      BAM/BED file or directory you want to calculate\n";
	print STDERR "  \$outdir     Output directory (default=".")\n";
	print STDERR "  \$reference  gene model downloaded from RSeQC website\n";
	print STDERR "  \$skewness   Skewness value\n";
	print STDERR "\n";
	print STDERR "Note:\n";
	print STDERR "  - When directory is specified, BAM/BED files under that directory will be computed\n";
	print STDERR "  - Download gene model of your species from the website\n";
	print STDERR "    URL: http://rseqc.sourceforge.net/#download-gene-models-update-on-08-07-2014\n";
	print STDERR "  - Mapping data from Genomics10X data have no 'chr' string in a reference column.\n";
	print STDERR "    Make sure reference names match\n";
	print STDERR "  - Index file of gene model will be created under same directory.\n";
	print STDERR "  - Two files will be created \$basename.txt \$basename.r.\n";
	print STDERR "\n";
	print STDERR "Requires:\n";
	print STDERR "  - samtools (https://samtools.github.io)\n";
	print STDERR "  - bedtools (https://bedtools.readthedocs.io/en/latest/)\n";
	print STDERR "\n";
	print STDERR "Author:\n";
	print STDERR "  - Akira Hasegawa (akira.hasegawa\@riken.jp)\n";
	print STDERR "\n";
	exit(1);
}
if(!`which samtools`){
	print STDERR "ERROR  samtools not installed\n";
	print STDERR "       Download from https://samtools.github.io/)\n";
	exit(1);
}
if(!`which bedtools`){
	print STDERR "ERROR  bedtools not installed\n";
	print STDERR "       Download from https://bedtools.readthedocs.io/\n";
	exit(1);
}
############################## MAIN ##############################
my @inputfiles=@ARGV;
my $reference=shift(@inputfiles);
my $outdir=(defined($opt_o))?$opt_o:".";
mkdir($outdir);
@inputfiles=expandFiles("\\.(bed|bam)\$",@inputfiles);
if(checkChrName($inputfiles[0])){$reference=noChrFile($reference);}
my $indexfile="$reference.index";
if(!-e $indexfile){calculatePercentile($reference,$indexfile);}
foreach my $inputfile(@inputfiles){
	my $startTime=time();
	my $convertedflag=0;
	my $basename=($inputfile=~/\.bam$/)?basename($inputfile,".bam"):basename($inputfile,".bed");
	if($inputfile=~/\.bam$/){$inputfile=convertBamToBed($reference,$inputfile);$convertedflag=1;}
	my @counts=geneBodyCoverage($indexfile,$inputfile,$reference);
	if($convertedflag){unlink($inputfile);}
	outputText($basename,@counts);
	outputR($basename,@counts);
	my $endTime=time();
	my $diff=$endTime - $startTime;
	print "$basename\t".pearsonMomentCoefficient(@counts)."\t".int($diff)." sec\n";
}
############################## checkChrName ##############################
sub checkChrName{
	my $inputfile=shift();
	my $hash={};
	if($inputfile=~/\.bam$/){
		open(IN,"samtools view -H $inputfile|");
		while(<IN>){
			if(/SN:(\S)+/){$hash->{$1}++;}
		}
		close(IN);
	}else{
		open(IN,$inputfile);
		while(<IN>){
			if($_!~/^\@/){last;}
			if(/SN:(\S)+/){$hash->{$1}++;}
		}
		close(IN);
	}
	foreach my $key(keys(%{$hash})){if($key=~/^chr/){return 0;}}
	return 1;
}
############################## noChrFile ##############################
sub noChrFile{
	my $reference=shift();
	open(IN,$reference);
	my $count=0;
	my $chrExists=0;
	while(<IN>){
		chomp;
		if(/^#/){next;}
	  my @tokens=split(/\t/);
		if($tokens[0]=~/^chr/){$chrExists=1;}
		if($count++>10){last;}
	}
	close(IN);
	if($chrExists==0){return $reference;}
	my $outfile=dirname($reference)."/".basename($reference,".bed").".nochr.bed";
	if(-e $outfile){return $outfile;}
	print STDERR "# Creating no chr version of gene model: $reference\n";
	open(IN,$reference);
	open(OUT,">$outfile");
	while(<IN>){
		if(/^#/){print "$_";next;}
	  chomp;
	  my @tokens=split(/\t/);
	  if($tokens[0]=~/^.+_(.+)v(\d+)_random$/){$tokens[0]="$1.$2";}
	  elsif($tokens[0]=~/^.+_(.+)v(\d+)_alt$/){$tokens[0]="$1.$2";}
	  elsif($tokens[0]=~/^.+_(.+)v(\d+)$/){$tokens[0]="$1.$2";}
	  elsif($tokens[0]=~/^chrM$/){$tokens[0]="MT";}
	  elsif($tokens[0]=~/^chr(.+)$/){$tokens[0]=$1;}
	  print OUT join("\t",@tokens)."\n";
	}
	close(IN);
	close(OUT);
	return $outfile;
}
############################## outputText ##############################
sub outputText{
	my @counts=@_;
	my $basename=shift(@counts);
	open(OUT,">$outdir/$basename.geneBodyCoverage.txt");
	my @numbers=();
	for(my $i=1;$i<101;$i++){push(@numbers,$i);}
	print OUT "Percentile	".join("\t",@numbers)."\n";
	print OUT "$basename\t".join("\t",@counts)."\n";
	close(OUT);
}
############################## outputR ##############################
sub outputR{
	my @counts=@_;
	my $basename=shift(@counts);
	my $basename2=$basename;
	$basename2=~s/[^\w\.]/_/g;
	open(OUT,">$outdir/$basename.geneBodyCoverage.r");
	print OUT "$basename2 <- c(".join(",",normalize(@counts)).")\n";
	print OUT "\n";
	print OUT "\n";
	print OUT "pdf(\"$outdir/$basename.geneBodyCoverage.curves.pdf\")\n";
	print OUT "x=1:100\n";
	print OUT "icolor = colorRampPalette(c(\"#7fc97f\",\"#beaed4\",\"#fdc086\",\"#ffff99\",\"#386cb0\",\"#f0027f\"))(1)\n";
	print OUT "plot(x,$basename2,type='l',xlab=\"Gene body percentile (5'->3')\", ylab=\"Coverage\",lwd=0.8,col=icolor[1])\n";
	print OUT "dev.off()\n";
	close(OUT);
}
############################## normalize ##############################
sub normalize{
	my @counts=@_;
	my $max=$counts[0];
	my $min=$counts[0];
	foreach my $count(@counts){
		if($count>$max){$max=$count;}
		if($count<$min){$min=$count;}
	}
	my @temp=();
	foreach my $count(@counts){
		if(($max-$min)!=0){push(@temp,($count-$min)/($max-$min));}
		else{push(@temp,0);}
	}
	return @temp;
}
############################## expandFiles ##############################
sub expandFiles{
	my @files=@_;
	my $suffix=shift(@files);
	my @temp=();
	foreach my $file(@files){
		if(-f $file){push(@temp,$file);next;}
		my $dh=DirHandle->new($file);
		foreach my $f($dh->read()){if($f=~/$suffix/){push(@temp,"$file/$f");}}
	}
	return @temp;
}
############################## convertBamToBed ##############################
sub convertBamToBed{
	my $reference=shift();
	my $bamfile=shift();
	my ($fh,$filteredfile)=tempfile(SUFFIX=>'.bam');
	print STDERR "# Filtering BAM file: $bamfile\n";
	system("samtools view -q 4 -bF 0x704 $bamfile > $filteredfile");
	#system("samtools view -q 0 -bF 0x704 $bamfile > $filteredfile");
	my ($fh2,$splitfile)=tempfile(SUFFIX=>'.bed');
	print STDERR "# Converting BAM to BED: $splitfile\n";
	system("bedtools bamtobed -splitD -i $filteredfile > $splitfile");
	close($fh2);
	unlink($filteredfile);
	my ($fh3,$intersectfile)=tempfile(SUFFIX=>'.bed');
	print STDERR "# Intersect BED with reference: $intersectfile\n";
	system("bedtools intersect -u -a $splitfile -b $reference > $intersectfile");
	close($fh3);
	unlink($splitfile);
	my $count=`samtools view -c -f 1 $bamfile`;
	chomp($count);
	if($count>0){
		print STDERR "# Remove intersecting paired-ends: $intersectfile\n";
		return removeOverlappingPairRegion($intersectfile);
	}else{
		return $intersectfile;
	}
}
############################## removeOverlappingPairRegion ##############################
sub removeOverlappingPairRegion{
	my $intersectfile=shift();
	my ($fh4,$sortfile)=tempfile(SUFFIX=>'.bed');
	close($fh4);
	system("sort -k 4 $intersectfile > $sortfile");
	unlink($intersectfile);
	my ($fh5,$removedfile)=tempfile(SUFFIX=>'.bed');
	open(IN,$sortfile);
	my $previd;
	my @pairs=();
	my $line=<IN>;
	while(defined($line)){
		chomp($line);
		my ($chr,$start,$end,$id,$score,$strand)=split(/\t/,$line);
		$line=undef;#next iteration from IN
		if($id=~/^(.+)\/2$/){
			my $id2=$1;
			if($id2 ne $previd){$previd=$id2;@pairs=();}
			for(my $i=0;$i<scalar(@pairs);$i++){
				my ($chr2,$start2,$end2)=@{$pairs[$i]};
				if($chr ne $chr2){next;}
				if(($start<$end2)&&($start2<$end)){
					if($start2>=$start){
						if($end2<$end){$line="$chr\t$end2\t$end\t$id\t$score\t$strand\n";}#pass to next iteration
						$end=$start2;
					}else{
						$start=$end2;
					}
				}
			}
		}elsif($id=~/^(.+)\/1$/){
			my $id2=$1;
			if($id2 ne $previd){$previd=$id2;@pairs=();}
			push(@pairs,[$chr,$start,$end]);
		}else{
			print STDERR "# Non paired ID found...\n";
		}
		if($start<$end){print $fh5 "$chr\t$start\t$end\t$id\t$score\t$strand\n";}
		if(!defined($line)){$line=<IN>;}
	}
	close(IN);
	unlink($sortfile);
	my ($fh6,$finalfile)=tempfile(SUFFIX=>'.bed');
	close($fh6);
	system("sort $removedfile > $finalfile");
	unlink($removedfile);
	return $finalfile;
}
############################## pearsonMomentCoefficient ##############################
sub pearsonMomentCoefficient{
	my @counts=@_;
	my $midValue=$counts[int(scalar(@counts)/2)];
	my $sigma=standardDeviation(@counts);
	my @tmp=();
	foreach my $count(@counts){
		if($sigma!=0){push(@tmp,(($count-$midValue)/$sigma)**3);}
		else{push(@tmp,0);}
	}
	return average(@tmp);
}
sub average{
	my @data=@_;
	my $total = 0;
	foreach(@data){$total += $_;}
	my $average=$total/scalar(@data);
	return $average;
}
sub standardDeviation{
	my @data=@_;
	my $average=average(@data);
	my $sqtotal = 0;
	foreach(@data){$sqtotal+=($average-$_)**2;}
	my $n=scalar(@data)-1;
	my $std=($sqtotal/$n)**0.5;
	return $std;
}
############################## calculatePercentile ##############################
sub calculatePercentile{
	my $reference=shift();
	my $indexfile=shift();
	print STDERR "# Calculating percentile of gene model: $reference...\n";
	open(OUT,">$indexfile");
	open(IN,$reference);
	while(<IN>){
		if(/^#/){next;}
		chomp;
		my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
		my @starts=split(/,/,$blockStarts);
		my @sizes=split(/,/,$blockSizes);
		my @exons=();
		for(my $i=0;$i<scalar(@starts);$i++){
			my $size=$sizes[$i];
			for(my $j=0;$j<$size;$j++){push(@exons,$start+$starts[$i]+$j);}
		}
		my $length=scalar(@exons);
		if($length<100){next;}
		my @percents=();
		for(my $i=1;$i<101;$i++){
			my $k=($length-1)*$i/100.0;
			my $f=floor($k);
			my $c=ceil($k);
			if($f==$c){
				push(@percents,int($exons[int($k)]));
			}else{
				my $d0=$exons[int($f)]*($c-$k);
				my $d1=$exons[int($c)]*($k-$f);
				#https://www.mihr.net/perl/rounding.html
				push(@percents,int($d0+$d1+0.50000000000008));
			}
		}
		print OUT "$id\t$chr\t$strand\t".join("\t",@percents)."\n";
	}
	close(IN);
	close(OUT);
}
############################## geneBodyCoverage ##############################
sub geneBodyCoverage{
	my $indexfile=shift();
	my $bedfile=shift();
	my $reference=shift();
	my $positions={};
	my $pairs={};
	print STDERR "# Loading reference positions: $indexfile\n";
	open(IN,$indexfile);
	my $positions={};
	while(<IN>){
		chomp;
		my ($id,$chr,$strand,@percents)=split(/\t/);
		if(!exists($positions->{$chr})){$positions->{$chr}={};}
		foreach my $position(@percents){$positions->{$chr}->{$position}=0;}
	}
	close(IN);
	print STDERR "# Counting positions: $bedfile\n";
	open(IN,$bedfile);
	while(<IN>){
		chomp;
		my ($chr,$start,$end,$id,$score,$strand)=split(/\t/);
		for(my $i=$start;$i<$end;$i++){
			if(exists($positions->{$chr}->{$i})){
				$positions->{$chr}->{$i}++;
			}
		}
	}
	close(IN);
	print STDERR "# Calculating genebody coverage: $bedfile\n";
	open(IN,$indexfile);
	my @counts=();
	for(my $i=0;$i<100;$i++){$counts[$i]=0;}
	#my $ids={};
	while(<IN>){
		chomp;
		my ($id,$chr,$strand,@percents)=split(/\t/);
		for(my $i=0;$i<100;$i++){
			my $pos=$percents[$i];
			if(exists($positions->{$chr}->{$pos})&&$positions->{$chr}->{$pos}>0){
				my $index=($strand eq "+")?$i:(99-$i);
				$counts[$index]+=$positions->{$chr}->{$pos};
				#$ids->{$id}=1;
			}
		}
	}
	close(IN);
	#open(IN,$reference);
	#while(<IN>){
	#	chomp;
	#	if(/^#/){print "$_\n";next;}
	#	my ($chr,$start,$end,$id,$score,$strand,$thickStart,$thickEnd,$itemRgb,$blockCount,$blockSizes,$blockStarts)=split(/\t/);
	#	if(!exists($ids->{$id})){next;}
	#	print "$_\n";
	#}
	#close(IN);
	return @counts;
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
