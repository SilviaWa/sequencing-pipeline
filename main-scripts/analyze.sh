#!/bin/zsh -e

scriptdir="$( cd "$( dirname "$0" )" && pwd )"

if [[ -z $@ ]]; then
  echo""
  echo "Oops... Proper usage of this pipeline is: "
  echo""
  echo "./analyze.sh <exfile> [<exfile>...]"
  echo ""
  echo "where each <exfile> is the path and name of an experiment"
  echo "file containing the species and fastq data locations. Examples"
  echo "of these files can be seen in the lists directory."
  echo ""
  echo "### EXAMPLES ###:"
  echo "./analyze.sh lists/lampe-pgm"
  echo "./analyze.sh lists/lampe-pgm lists/lampe-test-1"
  echo "./analyze.sh /home/myname/myexperiment"
  echo "./analyze.sh my_folder/*"
  echo "./analyze.sh lists/* 2>err.log | tee out.log"
  echo "where the last one will save any error output to err.log, and normal"
  echo "to out.log (and also to your screen"
fi

# A little length caching, to avoid unnecessary reading
# This is waaaay over-engineered... but oh well
readtmp="/tmp/fps"
mkdir -p $readtmp
cache () {
  fingerprint=`eval head -c 1M $1 | md5sum | cut -f1 -d' '`
  if [[ -s $readtmp/$fingerprint ]];
  then
    cacheresult=`cat $readtmp/$fingerprint`
  else
    cacheresult=$fingerprint
    false
  fi
}

bam_count () {
  if cache $1
  then
    readcount=$cacheresult
  else
    readcount=$(samtools flagstat $1 \
      | head -n1 | cut -f1 -d ' ' | tee $readtmp/$cacheresult)
  fi
}

fastq_count () {
  if cache $1
  then
    readcount=$cacheresult
  else
    readcount=$(echo "scale=0;$(eval wc -l $1 | cut -f1 -d' ')/4" \
      | bc | tee $readtmp/$cacheresult)
  fi
}

for experimentlist in "$@"; do
  samplename=${experimentlist:t}
  inputdir="./map-results/${samplename}"
  outputdir="./analysis/${samplename}"
  mkdir -p $outputdir
  cp $experimentlist $outputdir
  source $experimentlist #Gives us species and samplelist

  rm -f $outputdir/reads_summary.tsv
  rm -f $outputdir/genes_summary.tsv

  #mkdir -p $outputdir/fastqc
  #if [[ -z `ls $outputdir/fastqc` ]]; then
    #echo -n "Running fastQC for $samplename ... "
    #fastqc -t 12 -o $outputdir/fastqc -q $samplelist
    #echo "Done."
  #fi

  for filepath in $samplelist; do
    file=${filepath:t:r:r}

    echo "##################################################################"
    echo "$file has:"

    #csvformat="%s\t"
    #csvheader=(sample)
    #csvdata=($file)

    ############ READS for STAR ######################
    #if [[ -s $inputdir/star/$file/Aligned.filt.bam ]];
    #then
      #bam_count $inputdir/star/$file/Aligned.filt.bam
      #echo "STAR: $readcount reads"
      #csvformat+="%s\t"
      #csvheader+=(STAR)
      #csvdata+=($readcount)
    #fi
    ###################################################

    ############# READS for Tophat ####################
    #if [[ -s $inputdir/th/$file/accepted_hits.filt.bam ]];
    #then
      #bam_count $inputdir/th/$file/accepted_hits.filt.bam
      #echo "TOPHAT: $readcount reads"
      #csvformat+="%s\t"
      #csvheader+=(Tophat)
      #csvdata+=($readcount)
    #fi
    ##################################################

    ############ TOTAL READS #########################

    if [[ ${filepath: -7} == ".tar.gz" ]];
    then
      echo ".tar.gz formats are not yet supported, see Jason and mention tar 0xf <file> to him"
      exit -1
    elif [[ ${filepath: -3} == ".gz" ]];
    then
      readpath="<(unpigz -c ${filepath})"
    elif [[ ${filepath: -4} == ".bz2" ]];
    then
      readpath="<(lbzcat ${filepath})"
    else
      readpath=$filepath
    fi

    #fastq_count $readpath
    #echo "...out of $readcount total"
    #echo ""
    #csvformat+="%s\t"
    #csvheader+=(Input)
    #csvdata+=($readcount)
    ###################################################

    #csvformat+="\n"
    #if [[ ! -s $outputdir/reads_summary.tsv ]]; 
    #then
      #printf $csvformat $csvheader > $outputdir/reads_summary.tsv
    #fi
    #printf $csvformat $csvdata >> $outputdir/reads_summary.tsv

    #csvformat="%s\t"
    #csvheader=(sample)
    #csvdata=($file)

    ############# Gene Counts for STAR ##################
    #if [[ -s $inputdir/clstar/$file/genes.fpkm_tracking ]];
    #then
      #tail -n +2 $inputdir/clstar/$file/genes.fpkm_tracking \
        #| cut -f 1,10 \
        #| sort -k2nr \
        #| tee $inputdir/clstar/$file/genes.sorted.full \
        #| awk '{if ($2>0) print $1,$2;}' > $inputdir/clstar/$file/genes.sorted
      #mkdir -p $outputdir/clstar/$file
      #cp $inputdir/clstar/$file/genes.sorted* $outputdir/clstar/$file
      #stargenes=$((`wc -l $inputdir/clstar/$file/genes.sorted | cut -f1 -d' '` - 1))
      #echo "STAR: $stargenes genes"
      #csvformat+="%s\t"
      #csvheader+=(STAR)
      #csvdata+=($stargenes)

      #echo -n "Plotting IGV for STAR ... "
      #rm -rf $outputdir/clstar/$file/igv
      #mkdir -p $outputdir/clstar/$file/igv
      #python $scriptdir/plot_igv.py $outputdir/clstar/$file/igv $inputdir/star/$file/Aligned.filt.bam $species 
      #echo "Done."
    #fi
    ###################################################

    ############# Gene Counts for Tophat ################
    #if [[ -s $inputdir/clth/$file/genes.fpkm_tracking ]];
    #then
      #tail -n +2 $inputdir/clth/$file/genes.fpkm_tracking \
        #| cut -f 1,10 \
        #| sort -k2gr \
        #| tee $inputdir/clth/$file/genes.sorted.full \
        #| awk '{if ($2>0) print $1,$2;}' > $inputdir/clth/$file/genes.sorted
      #mkdir -p $outputdir/clth/$file
      #cp $inputdir/clth/$file/genes.sorted* $outputdir/clth/$file
      #thgenes=$((`wc -l $outputdir/clth/$file/genes.sorted | cut -f1 -d' '` - 1))
      #echo "TOPHAT: $thgenes genes"
      #csvformat+="%s\t"
      #csvheader+=(Tophat)
      #csvdata+=($thgenes)

      #echo -n "Plotting IGV for Tophat ... "
      #rm -rf $outputdir/clth/$file/igv
      #mkdir -p $outputdir/clth/$file/igv
      #python $scriptdir/plot_igv.py $outputdir/clth/$file/igv $inputdir/th/$file/accepted_hits.filt.bam $species
      #echo "Done."
    #fi
    ###################################################

    #csvformat+="\n"
    #if [[ ! -s $outputdir/genes_summary.tsv ]]; 
    #then
      #printf $csvformat $csvheader > $outputdir/genes_summary.tsv
    #fi
    #printf $csvformat $csvdata >> $outputdir/genes_summary.tsv

    ###################### ERCC Plots ################
    if [[ (! -s $outputdir/$file/star/ercc/plot.png) ]];
    then
      echo -n "Plotting ERCC ... "
      python $scriptdir/plot_ercc.py $inputdir/$file/star
      mkdir -p $outputdir/ercc
      cp $inputdir/$file/star/plot.png $outputdir/ercc/$file.png
      cp $inputdir/$file/star/plot.pdf $outputdir/ercc/$file.pdf
      echo "Done."
    fi
    ##################################################

    # Need to add comparison plot here (between what and what?)
    # ... or maybe comparison should be in a different script? for simplicity?
    echo "##################################################################"

  done # over files sample-list
done # over arguments
