#!/bin/bash
image=moirai2/skewc
sif=skewc.sif
user=`whoami`
workdir=`pwd`;
homedir=/home/$user
if [ -x "$(command -v singularity)" -a -f $sif ]; then
singularity shell \
  --bind $PWD \
  $sif
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:$homedir \
  --workdir $homedir \
  $image \
  bash
elif [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:$homedir \
  --workdir=$homedir \
  $image \
  bash
else
  echo "Please install docker, singularity, or udocker"
fi
