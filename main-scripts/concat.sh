#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo""
  echo "Oops... Proper usage of this pipeline is: "
  echo""
  echo "./$0 <input_directory> <output_directory> [sample_list.txt]"
  echo "Where <input_directory contains fastq.gz files"
  echo "which have 4 digit sample numbers eg: 1103_blah_blah.fastq.gz"
  echo "Also, you can supply an optional sample list as the third"
  echo "argument"
  echo ""
  echo "### EXAMPLES ###:"
  echo "./$0 /mnt/data/raw /mnt/data/processed"
  echo "./$0 /mnt/data/raw /mnt/data/processed sample_list.txt"
  exit -1
fi

IN=$1
OUT=$2

#this will create our output directory, if it doesn't already exist.
mkdir -p $2

if [[ $(ls -A $2) ]]; then
    echo ""
    echo "Oops, output folder $2 is nonempty"
    exit -1
fi


if [[ -z $3 ]]
then
    SAMPLES=$(for f in `find $IN -iname *fastq.gz `; do basename $f | cut -c 1-4; done | sort | uniq)
else
    SAMPLES=`cat $3`
fi

for s in $SAMPLES;
do
    NEW=$OUT/$s.fastq.bz2
    if [[ ! -s $NEW ]]; then
	FILES=$(find $IN -iname "$s"*.gz)
	echo "For sample $s, concatenating input files:"
	for f in $FILES;
	  do echo $f
	done
	echo "into new file: $NEW"
	echo ""
	#zcat $FILES | lbzip2 > $NEW
	#echo "... Done."
    fi
done

