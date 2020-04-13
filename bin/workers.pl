#!/usr/bin/perl
use strict 'vars';
use Cwd;
use File::Basename;
use Getopt::Std;
use File::Temp qw/tempfile/;
use vars qw($opt_q $opt_r $opt_s $opt_w);
getopts('qrs:w:');
my ($prgname,$prgdir,$prgsuffix)=fileparse($0);
if(scalar(@ARGV)<3){
  print STDERR "workers.pl [OPTIONS] INDIR OUTDIR command\n";
  print STDERR "workers.pl indir outdir 'samtools view -bSo \$out.bam \$in.sam'\n";
  print STDERR "It's better to use '' for specifying a command line.\n";
  print STDERR "OPTIONS: \n";
  print STDERR "   -q  Run with qsub command (default='bash')\n";
  print STDERR "   -r  Execute commands (default='show commands')\n";
  print STDERR "   -s  Specify sample runs (default='process all').\n";
  print STDERR "   -w  Path to a work directory\n";
  exit(1);
}
my $indir=$ARGV[0];
my $outdir=$ARGV[1];
my $command=$ARGV[2];
my $rootdir=Cwd::abs_path();
mkdir($indir);
mkdir($outdir);
if(defined($opt_q)){
  my ($fh,$tmpfile)=tempfile(SUFFIX=>'.sh');
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
#$indir=Cwd::abs_path($indir);
#$outdir=Cwd::abs_path($outdir);
my $insuffix;
if($command=~/\$in(\.[\.\dA-Za-z]+)/){$insuffix=$1;}
else{print STDERR "Please specify input with suffix information using \$in.\nExample: \$in.sam\n";exit(1);}
my $outsuffix;
if($command=~/\$out(\.[\.\dA-Za-z]+)/){$outsuffix=$1;}
else{print STDERR "Please specify output with suffix information using \$out.\nExample: \$out.bam\n";exit(1);}
my $workdir=defined($opt_w)?$opt_w:"workers";
$workdir=Cwd::abs_path($workdir);
mkdir($workdir);
my @infiles=`ls $indir/*$insuffix`;
my @outfiles=`ls $outdir`;
my $dones={};
foreach my $file(@outfiles){
  $file=basename($file,$outsuffix);
  chomp($file);
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
  my $outfile="$outdir/$basename$outsuffix";
  my $workfile="$workdir/$basename.sh";
  my $line=$command;
  $line=~s/\$in/$indir\/$basename/g;
  $line=~s/\$out/$outdir\/$basename/g;
  if(-e $outfile){next;}
  if(-e $workfile){next;}
  if(defined($opt_r)){
    open(OUT,">$workfile");
    print OUT "cd $rootdir\n";
    print OUT "$line\n";
    close(OUT);
    system("bash $workfile");
    unlink($workfile);
  }else{
    print STDERR "$line\n";
  }
  $count++;
}
