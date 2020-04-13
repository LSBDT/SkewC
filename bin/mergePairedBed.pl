while(<STDIN>){
  chomp;
  my @tokens=split(/\t/);
  if($tokens[0]=~/^.+_(.+)v(\d+)_random$/){$tokens[0]="$1.$2";}
  elsif($tokens[0]=~/^.+_(.+)v(\d+)_alt$/){$tokens[0]="$1.$2";}
  elsif($tokens[0]=~/^.+_(.+)v(\d+)$/){$tokens[0]="$1.$2";}
  elsif($tokens[0]=~/^chrM$/){$tokens[0]="MT";}
  elsif($tokens[0]=~/^chr(.+)$/){$tokens[0]=$1;}
  print join("\t",@tokens)."\n";
}
