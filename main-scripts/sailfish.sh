#!/bin/zsh -ex

# Read config.sh
. $(dirname $0)/../config.sh

mydate () {
    date +"%m/%d %H:%M:%S - " | tr -d '\n'
}

if [[ -z $@ ]]; then
  echo""
  echo "Oops... Proper usage of this pipeline is: "
  echo""
  echo "./map.sh <exfile> [<exfile>...]"
  echo ""
  echo "where each <exfile> is the path and name of an experiment"
  echo "file containing the species and fastq data locations. Examples"
  echo "of these files can be seen in the lists directory."
  echo ""
  echo "### EXAMPLES ###:"
  echo "./map.sh lists/lampe-pgm"
  echo "./map.sh lists/lampe-pgm lists/lampe-test-1"
  echo "./map.sh /home/myname/myexperiment"
  echo "./map.sh my_folder/*"
  echo "./map.sh lists/* 2>err.log | tee out.log"
  echo "where the last one will save any error output to err.log, and normal"
  echo "to out.log (and also to your screen"
fi


for experimentlist in "$@"; do
  samplename=$(basename $experimentlist)
  outputdir="./map-results/${samplename}"
  mkdir -p $outputdir
  cp $experimentlist $outputdir
  source $experimentlist #Gives us species and samplelist

  for filepath in $samplelist; do
    nice="0"
    filewoext=$(basename $filepath)
    file=${filewoext%%.*}

    if [[ ${filepath: -7} == ".tar.gz" ]];
    then
      echo ".tar.gz formats are not yet supported, see Jason"
      exit -1
    elif [[ ${filepath: -3} == ".gz" ]];
    then
      readpath="<(unpigz -c ${filepath})"
    elif [[ ${filepath: -4} == ".bz2" ]];
    then
      readpath="<(lbzcat ${filepath})"
    elif [[ ${filepath: -4} == ".zip" ]];
    then
      readpath="<(unzip -p ${filepath})"
    else
      readpath=$filepath
    fi

    currout=$outputdir/$file
    mkdir -p $currout
    echo "##################################################################"
    mydate
    echo "Processing file $file"
    if [[ ! -s $filepath ]];
    then
      echo "ERROR: $filepath Does not exist!!"
      exit -1
    fi

    ################################# HOST ##########################
    if [[ ! -s $currout/sf/$species/quant.sf ]];
    then
      mydate
      echo -n "Running Sailfish against host reference ... "
      mkdir -p $currout/sf/$species
      pushd $currout/sf/$species
      export LD_LIBRARY_PATH=$SAILFISHLIB
      eval nice -n $nice /usr/bin/time $SAILFISHBIN \
        quant -i /mnt/datab/refs/ens/mm10_candidates/ensembl/Sailfish \
        -l "T=SE:S=U" \
        -r $readpath \
        -p $THREADS \
        -o . &> out.log
      popd
      echo "Done."
    fi
    if [[ ! -s $currout/sf/genequant.sf ]];
      mydate
      echo -n "Aggregating transcripts to genes ... "
      mkdir -p $currout/sf/$species
      pushd $currout/sf/$species
      genesum -e quant.sf -k gene_name -g /mnt/datab/refs/ens/mm10_candidates/ensembl/genes.gtf -o genequant.sf
      popd
      echo "Done."
    then

    fi

    echo "##################################################################"

  done # over files sample-list
done # over arguments

mydate
echo ""

