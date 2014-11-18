#!/bin/zsh -e

if [[ $# -ne 3 ]]; then
  echo "ERROR: Incorrect arguments: "
  echo "$0 <output directory> <species> <host_reference_directory>"
  exit -1
fi

currout=$1
hostspecies=$2
hostrefdir=$3

if [[ ! -s $currout/star/$hostspecies/htseq.list.pris2 ]];
then
  pushd $currout/star/$hostspecies
  #htseq-count Aligned.filt.bam $hostrefdir/genes.gtf --stranded=no -f bam -i gene_name >! htseq.list.pris
  tail -5 htseq.list.pris >! htseq.log
  head -n -5 htseq.list.pris >! htseq.list

  # ERCC
  grep "^ERCC-" htseq.list >! ercc.list
  awk '{ sum+=$2 } END { print sum }' ercc.list >! ercc.count

  # Mitochondrial
  grep -i "^MT-" htseq.list >! mito.list
  awk '{ sum+=$2 } END { print sum }' mito.list >! mito.count

  awk '{ sum+=$2 } END { print sum }' htseq.list >! $hostspecies.annotated.count

  # Filter out all MT and ERCC reads
  sed -i '/^MT-/Id;/^ERCC-/Id' htseq.list
  # grep wouldn't work here for inplace operations ^^

  awk '{ sum+=$2 } END { print sum }' htseq.list >! $hostspecies.gene.count

  awk '{if ($2>0) print }' htseq.list \
    | sort -k2gr > htseq.0.list
  awk '{if ($2>3) print}' htseq.0.list > htseq.3.list
  awk '{if ($2>10) print}' htseq.3.list > htseq.10.list
  wc -l htseq.0.list | cut -f1 -d' ' > htseq.0.count
  wc -l htseq.3.list | cut -f1 -d' ' > htseq.3.count
  wc -l htseq.10.list | cut -f1 -d' ' > htseq.10.count
  popd
fi
