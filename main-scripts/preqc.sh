#!/bin/zsh

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

for experimentlist in "$@"; do
  samplename=${experimentlist:t}
  outputdir="./preqc-results/${samplename}"
  mkdir -p $outputdir
  cp $experimentlist $outputdir
  source $experimentlist #Gives us species and samplelist

  for filepath in $samplelist; do
    file=${filepath:t:r:r}
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

    echo "##################################################################"
    echo "$file"


    UNIQNAME="$(basename $(dirname $(dirname $filepath)))-$(basename $filepath)"
    echo $UNIQNAME
    mkdir -p $outputdir/fastqc/$UNIQNAME
    if [[ -z `ls $outputdir/fastqc/$UNIQNAME` ]]; then
      fastqc -o $outputdir/fastqc/$UNIQNAME -q $filepath
    fi

    mkdir -p $outputdir/diversity
    if [[ ! -s $outputdir/diversity/${file}_tophits ]]; then
      echo -n "Running diversity... "
      N=1000000
      rm -f $outputdir/diversity/${file}_tophits
      rm -f $outputdir/diversity/${file}_hist
      eval sed -n '2~4p' $readpath | cut -c -50 | python $scriptdir/diversity_calc.py $outputdir/diversity $file
      echo "Done."
    fi

  done #samplelist
done #experimentlist
