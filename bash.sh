#!/bin/bash
image=moirai2/skewc
user=`whoami`
workdir=`pwd`;
homedir=/home/$user
if [ -x "$(command -v udocker)" ];then
udocker run \
  --rm \
  --user=root \
  --volume=$workdir:$homedir \
  --workdir=$homedir \
  $image \
  bash
elif [ -x "$(command -v docker)" ]; then
docker run \
  -it \
  --rm \
  -v $workdir:$homedir \
  --workdir $homedir \
  $image \
  bash
else
  echo "Please install udocker or docker"
fi
