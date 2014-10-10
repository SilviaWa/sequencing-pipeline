#!/bin/zsh -e

if [[ $# -ne 3 ]]; then
  echo "ERROR: Incorrect arguments: "
  echo "$0 <output directory> <species> <host_reference_directory>"
  exit -1
fi

currout=$1
hostspecies=$2
hostrefdir=$3

if [[ ! -s $currout/star/$hostspecies/htseq.list ]];
then
  pushd $currout/star/$hostspecies
  htseq-count Aligned.filt.bam $hostrefdir/genes.gtf --stranded=no -f bam -i gene_name | head -n -5 >! htseq.list
  awk '{if ($2>0) print }' htseq.list \
    | sort -k2gr > htseq.0.list
  awk '{if ($2>3) print}' htseq.0.list > htseq.3.list
  awk '{if ($2>10) print}' htseq.3.list > htseq.10.list
  wc -l htseq.0.list | cut -f1 -d' ' > htseq.0.count
  wc -l htseq.3.list | cut -f1 -d' ' > htseq.3.count
  wc -l htseq.10.list | cut -f1 -d' ' > htseq.10.count
  popd
fi
############# Gene FPKMs #################
#if [[ ! -s $currout/clstar/$hostspecies/genes.full ]];
#then
  #mydate
  #echo -n "Filtering Gene counts ... "
  #pushd $currout/clstar/$hostspecies
  #tail -n +2 genes.fpkm_tracking \
    #| cut -f 1,10 \
    #| tee genes.full \
    #| awk '{if ($2>0) print }'  \
    #| sort -k2gr > genes.filt
  #awk '{if ($2>1) print}' genes.filt > genes.1.filt
  #awk '{if ($2>10) print}' genes.1.filt > genes.10.filt
  #wc -l genes.filt | cut -f1 -d' ' > genes.count
  #wc -l genes.1.filt | cut -f1 -d' ' > genes.1.count
  #wc -l genes.10.filt | cut -f1 -d' ' > genes.10.count
  #popd
  #echo "Done."
#fi
