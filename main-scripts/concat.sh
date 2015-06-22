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

IN=$1   # Input directory with fastq.gz files each from a different sequencing lane
OUT=$2  # Output directory for combined files

#this will create our output directory, if it doesn't already exist.
mkdir -p $2

if [[ $(ls -A $2) ]]; then # If there are files in our output directory
    echo ""
    echo "Oops, output folder $2 is nonempty" # Print an error message
    exit -1                                   # And exit with error code -1
fi


if [[ -z $3 ]]  # If there is no 3rd argument
then
    # Build up a samples list
    SAMPLES=$(
    # Look for any file in the IN dir ending in 'fastq.gz'
    for f in `find $IN -iname *fastq.gz `;
    do
      # Strip the directory and suffix from the file
      basename $f |
      # Take the first 4 characters from the stripped name 
      cut -c 1-4; 
    done | 
    # Sort the list alphabetically
    sort | 
    # Take only non-repeated names
    uniq)
else
    # Otherwise use the sample_list.txt file to get the list of 
    # samples on which to do the concatenation
    SAMPLES=`cat $3`
fi

# Now that we have sample names
for s in $SAMPLES;  # For each sample
do
    # Create a consolidated, single bz2 file in the OUT directory
    NEW=$OUT/$s.fastq.bz2
    # If the file does not exist
    if [[ ! -s $NEW ]]; then
    	# Find all files beginning with the 
      # sample name and ending in '.gz'
      FILES=$(find $IN -iname "$s"*.gz)
    	echo "For sample $s, concatenating input files:"
    	# Display each sample name
      for f in $FILES;
    	  do echo $f
    	done
      # And where we'll be storing the concatenated version
    	echo "into new file: $NEW"
    	echo ""
      # Do the actual concatenation by 
      # converting all '.gz' files into a single '.bz2' file
      # using as many CPU cores as possible
    	#zcat $FILES | lbzip2 > $NEW
    	echo "... Done."
    fi
done

