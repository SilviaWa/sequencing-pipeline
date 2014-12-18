#!/bin/zsh -e

if [[ $# -ne 3 ]]; then
  echo "ERROR: Incorrect arguments: "
  echo "$0 <output directory> <species> <host_reference_directory>"
  exit -1
fi

currout=$1
hostspecies=$2
hostrefdir=$3
currdir=`pwd`

if [[ ! -s $currout/bwa/$hostspecies.bed ]];
then
  pushd $currout/bwa
  coverageBed -abam $hostspecies.bam -b $hostrefdir/genes_only.gtf > $hostspecies.bed
  popd
fi

if [[ ! -s $currout/bwa/bed.list ]];
then
  pushd $currout/bwa
  python $currdir/misc-scripts/pull_bed.py $hostspecies.bed > bed.list
  popd
fi
