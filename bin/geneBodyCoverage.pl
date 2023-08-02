#!/usr/bin/perl
use File::Temp qw/tempfile/;
use File::Basename;
use POSIX qw(floor ceil);
use DirHandle;
use strict;
use Getopt::Std;
use Time::localtime;
use vars qw($opt_b $opt_g $opt_o $opt_p $opt_r $opt_t);
getopts('b:go:pr:t:');
############################## help ##############################
if(scalar(@ARGV)<2){
	print STDERR "\n";
	print STDERR "PROGRAM:\n";
	print STDERR "  - Does gene body coverage calculation using algorithm from RSeQC geneBody_coverage.py\n";
	print STDERR "  - RSeQC website: http://rseqc.sourceforge.net\n";
	print STDERR "  \n";
	print STDERR "USAGE: geneBodyCoverage.pl -o \$outdir \$reference \$input > \$skewness\n";
	print STDERR "  \$input      BAM/BED file or directory you want to calculate\n";
	print STDERR "  \$outdir     Output directory (default=".")\n";
	print STDERR "  \$reference  gene model downloaded from RSeQC website\n";
	print STDERR "  \$skewness   Skewness value\n";
	print STDERR "\n";
	print STDERR "Option:\n";
	print STDERR "     -b  barcodes.tsv from CellRanger 10X Genomics (default='none')\n";
	print STDERR "     -g  Calculate by gene (default='average')\n";
	print STDERR "     -o  Output directory (default='coverage')\n";
	print STDERR "     -p  Skip plot command lines in R output\n";
	print STDERR "     -t  temp directory (default='/tmp')\n";
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
my $tmpdir=defined($opt_t)?$opt_t:"/tmp";
if(!-e $tmpdir){mkdir($tmpdir);}
my @inputfiles=@ARGV;
my $reference=shift(@inputfiles);
my $outdir=(defined($opt_o))?$opt_o:"coverage";
my $regexp=(defined($opt_r))?$opt_r:"CB:Z:(\\S+)";
my $nopdf=$opt_p;
my $barcodefile=(defined($opt_b))?$opt_b:undef;
mkdir($outdir);
@inputfiles=expandFiles("\\.(bed|bam)\$",@inputfiles);
if(checkChrName($inputfiles[0])){$reference=noChrFile($reference);}
my $indexfile="$reference.index";
if(!-e $indexfile){calculatePercentile($reference,$indexfile);}
foreach my $inputfile(@inputfiles){
	my $convertedflag=0;
	my $startTime=time();
	my $basename=($inputfile=~/\.bam$/)?basename($inputfile,".bam"):basename($inputfile,".bed");
	if($inputfile=~/\.bam$/){$inputfile=convertBamToBed($reference,$inputfile,$regexp,$barcodefile);$convertedflag=1;}
	if(defined($opt_g)){mainGenes($inputfile,$indexfile,$basename,$nopdf,$startTime);}
	elsif(defined($barcodefile)){main10X($inputfile,$indexfile,$basename,$nopdf,$startTime);}
	else{mainNon10X($inputfile,$indexfile,$basename,$nopdf,$startTime);}
	if($convertedflag){unlink($inputfile);}
}
print STDERR "DONE\n";
############################## calculatePercentile ##############################
sub calculatePercentile{
	my $reference=shift();
	my $indexfile=shift();
	print STDERR "# Calculating percentile of gene model: $reference...\n";
	open(OUT,">$indexfile");
	my $reader=openFile($reference);
	while(<$reader>){
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
	close($reader);
	close(OUT);
}
############################## checkChrName ##############################
sub checkChrName{
	my $inputfile=shift();
	my $hash={};
	if($inputfile=~/\.bam$/){
		my $reader=openFile("samtools view -H $inputfile|");
		while(<$reader>){
			if(/SN:(\S+)/){$hash->{$1}++;}
		}
		close($reader);
	}else{
		my $reader=openFile($inputfile);
		while(<$reader>){
			if($_!~/^\@/){last;}
			if(/SN:(\S+)/){$hash->{$1}++;}
		}
		close($reader);
	}
	foreach my $key(keys(%{$hash})){if($key=~/^chr/){return 0;}}
	return 1;
}
############################## convertBamToBed ##############################
sub convertBamToBed{
	my $reference=shift();
	my $bamfile=shift();
	my $regexp=shift();
	my $barcodefile=shift();
	my ($fh,$filteredfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bam');
	if(defined($barcodefile)&&defined($regexp)){
		print STDERR "# Filtering BAM: $bamfile + $barcodefile\n";
		my $barcodes=readBarcodeFile($barcodefile);
		my ($writer,$writerfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.sam');
		my $reader=openFile("samtools view -H $bamfile|");
		while(<$reader>){print $writer $_;}
		close($reader);
		$reader=openFile("samtools view -q 4 -F 0x704 $bamfile|");
		while(<$reader>){
			my $line=$_;
			my $barcode;
			if($line=~/$regexp/){
				if(!exists($barcodes->{$1})){next;}
				$barcode=$1;
				if($barcode=~/^(.+)-1$/){$barcode=$1;}
			}else{next;}
			my @tokens=split(/\t/,$line);
			$tokens[0]="$barcode.".$tokens[0];
			print $writer join("\t",@tokens);
		}
		close($reader);
		close($writer);
		system("samtools view -bSo $filteredfile $writerfile");
		unlink($writerfile);
	}else{
		print STDERR "# Filtering BAM: $bamfile\n";
		system("samtools view -q 4 -bF 0x704 $bamfile > $filteredfile");
	}
	my ($fh2,$splitfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bed');
	close($fh2);
	print STDERR "# Converting BAM to BED: $splitfile\n";
	system("bedtools bamtobed -splitD -i $filteredfile > $splitfile");
	unlink($filteredfile);
	my ($fh3,$intersectfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bed');
	close($fh3);
	print STDERR "# Intersect BED with reference: $intersectfile\n";
	system("bedtools intersect -u -a $splitfile -b $reference > $intersectfile");
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
############################## calculateCoverage ##############################
sub calculateCoverage{
	my $positions=shift();
	my $inputfile=shift();
	my $reader=openFile($inputfile);
	my @counts=();
	for(my $i=0;$i<100;$i++){$counts[$i]=0;}
	while(<$reader>){
		chomp;
		my ($chr,$start,$end,$id,$score,$strand)=split(/\t/);
		for(my $i=$start;$i<$end;$i++){
			if(exists($positions->{$chr}->{$i})){
				my @indeces=@{$positions->{$chr}->{$i}};
				foreach my $index(@indeces){$counts[$index]++;}
			}
		}
	}
	close($reader);
	return @counts;
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
############################## geneBodyCoverage ##############################
sub geneBodyCoverage{
	my $indexfile=shift();
	my $positions=shift();
	my $reader=openFile($indexfile);
	my @counts=();
	for(my $i=0;$i<100;$i++){$counts[$i]=0;}
	while(<$reader>){
		chomp;
		my ($id,$chr,$strand,@percents)=split(/\t/);
		for(my $i=0;$i<100;$i++){
			my $pos=$percents[$i];
			if(exists($positions->{$chr}->{$pos})&&$positions->{$chr}->{$pos}>0){
				my $index=($strand eq "+")?$i:(99-$i);
				$counts[$index]+=$positions->{$chr}->{$pos};
			}
		}
	}
	close($reader);
	return @counts;
}
############################## geneBodyCoverageByGenes ##############################
sub geneBodyCoverageByGenes{
	my $indexfile=shift();
	my $positions=shift();
	my $reader=openFile($indexfile);
	my $hash={};
	while(<$reader>){
		chomp;
		my @counts=();
		my $total=0;
		for(my $i=0;$i<100;$i++){$counts[$i]=0;}
		my ($id,$chr,$strand,@percents)=split(/\t/);
		for(my $i=0;$i<100;$i++){
			my $pos=$percents[$i];
			if(exists($positions->{$chr})&&exists($positions->{$chr}->{$pos})&&$positions->{$chr}->{$pos}>0){
				$total++;
				my $index=($strand eq "+")?$i:(99-$i);
				$counts[$index]+=$positions->{$chr}->{$pos};
			}
		}
		if($total>0){$hash->{$id}=\@counts;}
	}
	close($reader);
	return $hash;
}
############################## loadPositions ##############################
sub loadPositions{
	my $indexfile=shift();
	my $bedfile=shift();
	my $positions=shift();
	$positions=loadReferences($indexfile,$positions);
	print STDERR "# Counting positions: $bedfile\n";
	my $reader=openFile($bedfile);
	while(<$reader>){
		chomp;
		my ($chr,$start,$end,$id,$score,$strand)=split(/\t/);
		for(my $i=$start;$i<$end;$i++){
			if(exists($positions->{$chr}->{$i})){
				$positions->{$chr}->{$i}++;
			}
		}
	}
	close($reader);
	return $positions;
}
############################## loadReferences ##############################
sub loadReferences{
	my $indexfile=shift();
	my $positions=shift();
	if(!defined($positions)){
		$positions={};
		print STDERR "# Loading reference positions: $indexfile\n";
		my $reader=openFile($indexfile);
		while(<$reader>){
			chomp;
			my ($id,$chr,$strand,@percents)=split(/\t/);
			if(!exists($positions->{$chr})){$positions->{$chr}={};}
			foreach my $position(@percents){$positions->{$chr}->{$position}=0;}
		}
		close($reader);
	}else{
		foreach my $chr(keys(%{$positions})){
			foreach my $position(keys(%{$positions->{$chr}})){$positions->{$chr}->{$position}=0;}
		}
	}
	return $positions;
}
############################## loadIndex ##############################
sub loadIndex{
	my $indexfile=shift();
	my $positions={};
	print STDERR "# Loading reference index: $indexfile\n";
	my $reader=openFile($indexfile);
	while(<$reader>){
		chomp;
		my ($id,$chr,$strand,@percents)=split(/\t/);
		if(!exists($positions->{$chr})){$positions->{$chr}={};}
		for(my $i=0;$i<100;$i++){
			my $position=$percents[$i];
			my $index=($strand eq "+")?$i:(99-$i);
			if(exists($positions->{$chr}->{$position})){push(@{$positions->{$chr}->{$position}},$index);}
			else{$positions->{$chr}->{$position}=[$index];}
		}
	}
	close($reader);
	return $positions;
}
############################## main10X ##############################
sub main10X{
	my $inputfile=shift();
	my $indexfile=shift();
	my $basename=shift();
	my $nopdf=shift();
	my $startTime=shift();
	my ($txtHandler,$txtFile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.txt');
	my @numbers=();
	for(my $i=1;$i<101;$i++){push(@numbers,$i);}
	print $txtHandler "Percentile\t".join("\t",@numbers)."\n";
	my ($rHandler,$rFile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.r');
	my $reader=openFile("sort -k 4 $inputfile|");
	my $positions=loadIndex($indexfile);
	my $previousBarcode;
	my $count=0;
	my @counts=();
	while(<$reader>){
		chomp;
		my $line=$_;
		my ($chr,$start,$end,$id,$score,$strand)=split(/\t/,$line);
		my @tokens=split(/\./,$id);
		my $barcode=$tokens[0];
		if($barcode ne $previousBarcode){
			if($count>0){
				print $txtHandler "$previousBarcode\t".join("\t",@counts)."\n";
				my $basename2=$basename;
				$basename2=~s/[^\w\.]/_/g;
				print $rHandler "$previousBarcode <- c(".join(",",normalize(@counts)).")\n";
				my $pearson=pearsonMomentCoefficient(@counts);
				print "$previousBarcode\t$pearson\n";
				$count=0;
				for(my $i=0;$i<100;$i++){$counts[$i]=0;}
			}
			$previousBarcode=$barcode;
		}
		for(my $i=$start;$i<$end;$i++){
			if(exists($positions->{$chr}->{$i})){foreach my $index(@{$positions->{$chr}->{$i}}){$counts[$index]++;}}
		}
		$count++;
	}
	close($reader);
	if($count>0){
		print $txtHandler "$previousBarcode\t".join("\t",@counts)."\n";
		my $basename2=$basename;
		$basename2=~s/[^\w\.]/_/g;
		print $rHandler "$previousBarcode <- c(".join(",",normalize(@counts)).")\n";
		my $pearson=pearsonMomentCoefficient(@counts);
		print "$previousBarcode\t$pearson\n";
	}
	if(!$nopdf){
		my $basename2=$basename;
		$basename2=~s/[^\w\.]/_/g;
		print $rHandler "\n";
		print $rHandler "\n";
		print $rHandler "pdf(\"$outdir/$basename.geneBodyCoverage.curves.pdf\")\n";
		print $rHandler "x=1:100\n";
		print $rHandler "icolor = colorRampPalette(c(\"#7fc97f\",\"#beaed4\",\"#fdc086\",\"#ffff99\",\"#386cb0\",\"#f0027f\"))(1)\n";
		print $rHandler "plot(x,$basename2,type='l',xlab=\"Gene body percentile (5'->3')\", ylab=\"Coverage\",lwd=0.8,col=icolor[1])\n";
		print $rHandler "dev.off()\n";
	}
	close($rHandler);
	close($txtHandler);
	rename($txtFile,"$outdir/$basename.geneBodyCoverage.txt");
	rename($rFile,"$outdir/$basename.geneBodyCoverage.r");
	my $endTime=time();
	my $diff=$endTime-$startTime;
	print "computation time\t$diff sec\n";
}
############################## mainGenes ##############################
sub mainGenes{
	my $inputfile=shift();
	my $indexfile=shift();
	my $basename=shift();
	my $nopdf=shift();
	my $startTime=shift();
	print STDERR "# Calculating genebody coverage by genes: $inputfile\n";
	my $positions=loadPositions($indexfile,$inputfile);
	my $counts=geneBodyCoverageByGenes($indexfile,$positions);
	outputTextByGenes($basename,$counts);
	outputJsonByGenes($basename,$counts);
	foreach my $id(sort{$a cmp $b}keys(%{$counts})){
		my @array=@{$counts->{$id}};
		my $pearson=pearsonMomentCoefficient(@array);
		print "$id\t$pearson\n";
	}
	my $endTime=time();
	my $diff=$endTime-$startTime;
	print "computation time\t$diff sec\n";
}
############################## mainNon10X ##############################
sub mainNon10X{
	my $inputfile=shift();
	my $indexfile=shift();
	my $basename=shift();
	my $nopdf=shift();
	my $startTime=shift();
	print STDERR "# Calculating genebody coverage: $inputfile\n";
	my $positions=loadPositions($indexfile,$inputfile);
	my @counts=geneBodyCoverage($indexfile,$positions);
	outputText($basename,@counts);
	outputR($basename,$nopdf,@counts);
	my $pearson=pearsonMomentCoefficient(@counts);
	print "$basename\t$pearson\n";
	my $endTime=time();
	my $diff=$endTime-$startTime;
	print "computation time\t$diff sec\n";
}
############################## noChrFile ##############################
sub noChrFile{
	my $reference=shift();
	my $reader=openFile($reference);
	my $count=0;
	my $chrExists=0;
	while(<$reader>){
		chomp;
		if(/^#/){next;}
	  my @tokens=split(/\t/);
		if($tokens[0]=~/^chr/){$chrExists=1;}
		if($count++>10){last;}
	}
	close($reader);
	if($chrExists==0){return $reference;}
	my $outfile=dirname($reference)."/".basename($reference,".bed").".nochr.bed";
	if(-e $outfile){return $outfile;}
	print STDERR "# Creating no chr version of gene model: $reference\n";
	my $reader=openFile($reference);
	open($reader,$reference);
	open(OUT,">$outfile");
	while(<$reader>){
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
	close($reader);
	close(OUT);
	return $outfile;
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
############################## openFile ##############################
sub openFile{
	my $path=shift();
	if($path=~/^(.+\@.+)\:(.+)$/){
		if($path=~/\.gz(ip)?$/){return IO::File->new("ssh $1 'gzip -cd $2 2>/dev/null'|");}
		elsif($path=~/\.bz(ip)?2$/){return IO::File->new("ssh $1 'bzip2 -cd $2 2>/dev/null'|");}
		elsif($path=~/\.bam$/){return IO::File->new("ssh $1 'samtools view $2 2>/dev/null'|");}
		else{return IO::File->new("ssh $1 'cat $2 2>/dev/null'|");}
	}else{
		if($path=~/\.gz(ip)?$/){return IO::File->new("gzip -cd $path|");}
		elsif($path=~/\.bz(ip)?2$/){return IO::File->new("bzip2 -cd $path|");}
		elsif($path=~/\.bam$/){return IO::File->new("samtools view $path|");}
		else{return IO::File->new($path);}
	}
}
############################## outputJsonByGenes ##############################
sub outputJsonByGenes{
	my $basename=shift();
	my $counts=shift();
	my @lines=();
	open(OUT,">$outdir/$basename.geneBodyCoverage.json");
	print OUT "{\n";
	my @ids=sort{$a cmp $b}keys(%{$counts});
	my $total=scalar(@ids);
	for(my $i=0;$i<$total;$i++){
		my $id=$ids[$i];
		print OUT "\"$id\":";
		my @array=@{$counts->{$id}};
		print OUT "[".join(",",@array)."]";
		if($i+1<$total){print OUT ",\n";}
		else{print OUT "\n";}
	}
	print OUT "}\n";
	close(OUT);
}
############################## outputR ##############################
sub outputR{
	my @counts=@_;
	my $basename=shift(@counts);
	my $nopdf=shift(@counts);
	my $basename2=$basename;
	$basename2=~s/[^\w\.]/_/g;
	open(OUT,">$outdir/$basename.geneBodyCoverage.r");
	print OUT "$basename2 <- c(".join(",",normalize(@counts)).")\n";
	if($nopdf){return;}
	print OUT "\n";
	print OUT "\n";
	print OUT "pdf(\"$outdir/$basename.geneBodyCoverage.curves.pdf\")\n";
	print OUT "x=1:100\n";
	print OUT "icolor = colorRampPalette(c(\"#7fc97f\",\"#beaed4\",\"#fdc086\",\"#ffff99\",\"#386cb0\",\"#f0027f\"))(1)\n";
	print OUT "plot(x,$basename2,type='l',xlab=\"Gene body percentile (5'->3')\", ylab=\"Coverage\",lwd=0.8,col=icolor[1])\n";
	print OUT "dev.off()\n";
	close(OUT);
}
############################## outputText ##############################
sub outputText{
	my @counts=@_;
	my $basename=shift(@counts);
	open(OUT,">$outdir/$basename.geneBodyCoverage.txt");
	my @numbers=();
	for(my $i=1;$i<101;$i++){push(@numbers,$i);}
	print OUT "Percentile\t".join("\t",@numbers)."\n";
	print OUT "$basename\t".join("\t",@counts)."\n";
	close(OUT);
}
############################## outputTextByGenes ##############################
sub outputTextByGenes{
	my $basename=shift();
	my $counts=shift();
	open(OUT,">$outdir/$basename.geneBodyCoverage.txt");
	my @numbers=();
	for(my $i=1;$i<101;$i++){push(@numbers,$i);}
	print OUT "Percentile\t".join("\t",@numbers)."\n";
	foreach my $id(sort{$a cmp $b}keys(%{$counts})){
		my @array=@{$counts->{$id}};
		print OUT "$id\t".join("\t",@array)."\n";
	}
	close(OUT);
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
############################## readBarcodeFile ##############################
sub readBarcodeFile{
	my $barcode=shift();
	my $barcodes={};
	my $reader=openFile($barcode);
	while(<$reader>){chomp;$barcodes->{$_}++;}
	close($reader);
	return $barcodes;
}
############################## removeOverlappingPairRegion ##############################
sub removeOverlappingPairRegion{
	my $intersectfile=shift();
	my ($fh4,$sortfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bed');
	close($fh4);
	system("sort -k 4 $intersectfile > $sortfile");
	unlink($intersectfile);
	my ($fh5,$removedfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bed');
	my $reader=openFile($sortfile);
	my $previd;
	my @pairs=();
	my $line=<$reader>;
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
		if(!defined($line)){$line=<$reader>;}
	}
	close($reader);
	unlink($sortfile);
	my ($fh6,$finalfile)=tempfile(DIR=>$tmpdir,SUFFIX=>'.bed');
	close($fh6);
	system("sort $removedfile > $finalfile");
	unlink($removedfile);
	return $finalfile;
}