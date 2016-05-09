***It is highly recommended that the list of sample names sent to the sequencing center contain names that have the same length as this length will be used to label the files.  This simplifies things later on.***

#Using the pipeline to process sequencing data.

----------
##To Get Started

- All files should be on Github (files may need small amounts of editing for your particular sequences).

- To get the most current versions type: `git pull`

- To upload changes you have made, type: `git commit -am "Describe my changes for comments"`
- If you haven't `git pull` recently, `git commit` may not work.
- If you have no files at all, then type `git clone https://github.com/chapkinlab/sequencing-pipeline.git`

----------

1. Sequencing files should have been received on an external hard drive or downloaded from a server.  Place these files on the NAS in a folder that is descriptive but does not use spaces (Linux has issues).  Use `-` or `_` in the folder name.  Be sure to check the checksums if available (this is key to be sure there is no corruption of the files when copied).  To get files, be in the directory you want them placed then:
	
	`wget --user=Chapkin --pasword=pswrd location.of.files.downloading`

	Use `md5sum filename` or `sum filename` depending on the type of checksum.  You may need to contact the sequencing core facility.


1. Place a **copy** onto the computer that you plan to use for the analysis (oracle - `/mnt/datab`, sequencer - `/mnt/data1`).  The original should never be altered.  If the files are in a `.tar` archive, do not untar on the NAS.  Be sure to check that the files are copied okay using the md5sum or checksum.

	Use cp: `cp location.and.file.copying.from location.and.file.copying.to`

1. You will need to be sure you have space on the computer hard drive.  Check for hard drive space, `df -h`  You will need space on `data1/datab` and your `/home` directory.  Each `.bam` file produced will need about 1 GB of space.
2. Once the files are on the computer for processing, untar them:
	`tar -xvf file.tar`

	Once complete, you can remove the .tar files to save on space.  There are several files that we do not need (the "FILTERED" and "ADAPTOR" and Undetermined).  Remove these:
	`rm -r files.to.remove`

1. All programs are on GitHub in the sequence-pipeline.  You will need these on your Linux home space.



1. If your sequences were run on multiple lanes, you will need to concatenate your files so each sample has only one file.  Use `concat.sh`.  **If you edit a program and change the filename you will need to change the file permissions:** `chmod u+x filename` or `chmod 777 filename`.  I find as each experiment uses different lengths for names, I change the program to grab the appropriate number of characters to capture the name.  Now you will be able to execute the new programs.  Also, the section that writes the output has been starred out.  Once you are sure everything is working okay, remove the stars (##) and proceed.
		
	`main-scripts/concat.sh location.of.files.to.concat location.to.place.concatenated.files`

	If you do not need to concatenate your files, you will need to convert the .gz to .bz2 as follows:
	`gunzip -c < file.gz | bzip2 -c > file.bz2`
	
	The `concat.sh` program includes this step.



1. Some reads need to be trimmed, such as those libraries created using the NuGen Ovation RNA-Seq Single cell system (these need to have the first 8 nucleotides trimmed as they are part of the adaptor, not the sample).  Trim after concatenating so all of a single sample is trimmed at the same time.

	`bunzip2 -kc filename | fastx_trimmer -f9 | bzip2 > new_name_of_file`

	The -f indicates the first nucleotide to be kept and the default for the last is all so (-f9) starts keeping the nucleotides from bp 9 to the end, effectively trimming the first 8.

1. Now a list needs to be made of all samples.  This can be facilitated by making a digital list of all the files in your sequencing folder that we placed on the Linux computer.  This can be started by using the following command:  `ls /folder-where-my-sequences-are/* > listname.txt`

	You want to be in the sequencing-pipeline so that the list contains the correct map to the files.  Now you can open the list file in your favorite Linux writing program (Vim, Nano & others).  The key is to make a file that looks like the following:
```
    species="mm10"
	samplelist=(\
	/mnt/data1/manasvi-stem-010113/255neg100ng_RNA_GATCAG_R1.fastq.gz \
	/mnt/data1/manasvi-stem-010113/255neg10ng_RNA_CTTGTA_R1.fastq.gz \
	/mnt/data1/manasvi-stem-010113/255neg10neg_RNA_GGCTAC_R1.fastq.gz \
	)
```

**Some key features:**

- Species needs to be listed by the name of the files the sequences will be mapped to (with Ensembl we would use "mouse".  Oracle is `grch38-human` & `grcm39-mouse` currently).  Check the directory name.  The location will be listed in the `config.sh`.
- The sample list needs to list all the files with a space at the end before the `\`.  The backlash allow the next line to be read as if a single space was there.  There cannot be a space after the `\`.
- The list will be used with many of the following programs so having this correct will save a lot of time.

 
1. Next, if the sequencing facility has not done so, you can run `preqc.sh` to check on the quality of the sequencing.  This program is usually run from the sequencing pipeline directory.  Below is an example:  `main-scripts/preqc.sh lists/FADS1`
2. Now that you know that the sequences have passed QC, it is time to map them against a reference genome.  The genome that you will reference against should be the first line in your "list".  This program is also usually run from the sequencing pipeline directory.  Below is an example:
	`main-scripts/map.sh lists/FADS1 2> err.log | tee out.log`

	Adding the text after the 2 will print the log and what is printed onto the screens into a written log that you can check later if there is a problem.  This records exactly what was done.

	**Note:**  If your samples are stranded, then you will need to edit the htseq-count program to remove the `-stranded no` from the htseq-count portion of the program.  The single cell NuGen kit produces stranded libraries.

	If you are checking to see if your files are being produced, be sure to use: `du -sh *` not `ls -lh` to get accurate results.  Often `ls -lh` will show 0 in the files which is incorrect.  If the run get killed for some reason (such as the ssh connection was dropped - it happens), be sure to delete the last samples output folder as it most likely didn't finish and when you restart, it will be skipped as the program will think it finished that sample.
1. In order to tell how the mapping went, we would like to see an overview (summary).  You may need to create a "key" file as a comma delimited filetype (it is not necessary with the current set up).  You have to have the first column be your sample name with a title of the sample.  The other columns may indicate the different treatment groups.  This "key" will also be used when running cuffdiff (we don't use cuffdiff anymore but use EdgeR instead) for comparisons between groups/differential expression.  Run `sumary.py` in order to create a .csv file with that info.  `main-scripts/summary.py lists/FADS1 FADS1-key.csv`  The `summary.py` program also creates the lists of genes with counts for each sample.
2. Most will do EdgeR on their own computers rather than run it on a Linux based computer.  Now you are ready to find the differentially expressed genes.  You will need to edit `run-comparisons.py` to set up the comparisons you want to run.  Run `run-comparisons.py`.    
	`main-scripts/run-comparisons.py lists/FADS1 FADS1-key.csv`
Be sure that the sb.check_call line (shoud be the last line) is uncommented (no #)

Need to add EdgeR usage information.

Links to Kumaran/Radi videos:

[https://www.youtube.com/watch?v=kXnN28aSUMA](http://www.youtube.com/watch?v=kXnN28aSUMA)

[https://www.youtube.com/watch?v=FtpHgvSFLIk](https://www.youtube.com/watch?v=FtpHgvSFLIk)
