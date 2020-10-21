#!/usr/bin/perl
use strict 'vars';
use Cwd;
use File::Basename;
use Getopt::Std;
use File::Temp qw/tempfile/;
use vars qw($opt_q $opt_h $opt_r $opt_s $opt_w);
getopts('hqrs:w:');
my ($prgname,$prgdir,$prgsuffix)=fileparse($0);
if(scalar(@ARGV)<3){
  print STDERR "\n";
  print STDERR "Command: workers.pl [OPTIONS] INDIR OUTDIR 'CMD'\n";
  print STDERR "   INDIR  input directory to base on\n";
  print STDERR "  OUTDIR  output directory to output\n";
  print STDERR "     CMD  Command line to execute \n";
  print STDERR "      -h  Show help\n";
  print STDERR "      -q  Run with qsub command (default='bash')\n";
  print STDERR "      -r  Execute commands (default='show commands')\n";
  print STDERR "      -s  Specify sample runs (default='process all').\n";
  print STDERR "      -w  Path to a work directory\n";
  print STDERR "\n";
  print STDERR "Author: Akira Hasegawa (akira.hasegawa\@riken.jp)\n";
  print STDERR "Version: 2020/06/04\n";
  print STDERR "\n";
  print STDERR "Example:\n";
  print STDERR "  1) workers.pl indir outdir 'cat \$in.txt | sort | uniq -c > \$out.txt'\n";
  print STDERR "  2) workers.pl samdir bamdir 'samtools view -bSo \$out.bam \$in.sam'\n";
  print STDERR "  3) workers.pl bam sort 'samtools sort -f \$in.bam \$out.bam'\n";
  print STDERR "  4) workers.pl bam coverage 'geneBody_coverage.py -i \$in.bam -r hg38.bed -o \$outdir/\$basename > \$out.log'\n";
  print STDERR "\n";
  if(defined($opt_h)){
    print STDERR "\n";
    print STDERR "Usage: \n";
    print STDERR "  Process command line(s) on all files under input directory\n";
    print STDERR "  If output directory exists in output directory, command will not be executed\n";
    print STDERR "\n";
    print STDERR "Variables:\n";
    print STDERR "  \$basename  basename of a file\n";
    print STDERR "  \$indir     input directory\n";
    print STDERR "  \$outdir    output directory\n";
    print STDERR "  \$in        input path\n";
    print STDERR "  \$out       output path\n";
    print STDERR "\n";
  }
  exit();
}
my $indir=$ARGV[0];
my $outdir=$ARGV[1];
my $command=$ARGV[2];
my $tmpdir=(-e "/tmp")?"/tmp":".";
my $rootdir=Cwd::abs_path();
mkdir($indir);
mkdir($outdir);
if(defined($opt_q)){
  my ($fh,$tmpfile)=tempfile(DIR=>$tmpdir,TEMPLATE=>'wksXXXXXX',SUFFIX=>'.sh');
  print $fh "cd $rootdir\n";
  $prgdir=Cwd::abs_path($prgdir);
  my $line="perl $prgdir/$prgname -r";
  if(defined($opt_s)){$line.=" -s $opt_s"}
  if(defined($opt_w)){$line.=" -w $opt_w"}
  $line.=" $indir $outdir '$command'";
  print $fh "$line\n";
  close($fh);
  system("qsub $tmpfile");
  exit();
}
my $insuffix;
if($command=~/\$in(\.[\.\dA-Za-z]+)/){$insuffix=$1;}
else{print STDERR "Please specify input with suffix information using \$in.\nExample: \$in.sam\n";exit(1);}
my $outsuffix;
if($command=~/\$out(\.[\.\dA-Za-z]+)/){$outsuffix=$1;}
else{print STDERR "Please specify output with suffix information using \$out.\nExample: \$out.bam\n";exit(1);}
my $workdir=defined($opt_w)?$opt_w:"workers";
$workdir=Cwd::abs_path($workdir);
mkdir($workdir);
my $lockfile="$workdir/lockfile";
my @infiles=`ls $indir/*$insuffix`;
my @outfiles=`ls $outdir`;
my $dones={};
foreach my $file(@outfiles){
  chomp($file);
  $file=basename($file,$outsuffix);
  $dones->{$file}=1;
}
my @inputs=();
foreach my $file(@infiles){
  chomp($file);
  $file=basename($file,$insuffix);
  if(!exists($dones->{$file})){push(@inputs,$file);}
}
my $count=0;
foreach my $basename(sort {$a cmp $b} @inputs){
  if(defined($opt_s)&&$count>=$opt_s){last;}
  while(!symlink("$prgdir/$prgname",$lockfile)){sleep(1);}
  my $outfile="$outdir/$basename$outsuffix";
  my $workfile="$workdir/$basename.sh";
  my $line=$command;
  $line=~s/\$indir/$indir/g;
  $line=~s/\$\{indir\}/$indir/g;
  $line=~s/\$outdir/$outdir/g;
  $line=~s/\$\{outdir\}/$outdir/g;
  $line=~s/\$in/$indir\/$basename/g;
  $line=~s/\$\{in\}/$indir\/$basename/g;
  $line=~s/\$out/$outdir\/$basename/g;
  $line=~s/\$\{out\}/$outdir\/$basename/g;
  $line=~s/\$basename/$basename/g;
  $line=~s/\$\{basename\}/$basename/g;
  if(-e $outfile){unlink($lockfile);next;}
  elsif(-e $workfile){unlink($lockfile);next;}
  else{unlink($lockfile);}
  if(defined($opt_r)){
    open(OUT,">$workfile");
    print OUT "cd $rootdir\n";
    print OUT "$line\n";
    close(OUT);
    system("bash $workfile");
    unlink($workfile);
  }else{print STDERR "$line\n";}
  $count++;
}
