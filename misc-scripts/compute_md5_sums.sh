#!/usr/bin/zsh
# Purpose: 	Computes md5sums of a list of files and compares them to given values
# Expects: 	One argument:	
# 					- Space delimited file, in the same directory as the untarred fastq files,
# 						with the first column being a md5sum
# 						and the second column being the file name, which has previously been summed

if (! [[ -e $1 ]]); then
	print "File does not exist"
	# Exit with an error code of 1	
	return 1
else
	#Set the precomputed vendor md5sum file name to the first argument
	file=$1
fi

 # Change into the MD5SUMS file's directory
cd $(dirname $file)

# Create a list of the known md5sums by taking only the filename, since we're already
# in the correct directory, and looking in the first column for an md5sum, 
# which is assumed to be the format of the agrument file,
known_sums=($(cat $(basename $file) | cut -d' ' -f1))

# Similarly create the list of known file names from the agrument file's third column
# (the 2nd column comes out to be just whitespace since the delimiter here is whitespace)
file_names=($(cat $(basename $file) | cut -d' ' -f3))

print "Working ..."
# Once for every file do the following:
for (( i = 1; i <= ${#file_names}; i++))
do
	# Compute the average sum from the file name, by taking the first column of the output
	# of the md5sum command
	computed_sum=$(md5sum $file_names[i] | cut -d' ' -f1)
	# Check if the sum from the agrument file equals the computed sum, if not	
	if [[ $known_sums[i] != $computed_sum ]]; then
		print "Sum mismatch for file: \t" $file_names[i]
	fi
done

# If nothing was printed we successfully matched all the sums; Notify the user
print "All sums matched!"
# Successful, no error code
return 0
