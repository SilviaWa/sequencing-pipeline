#!/bin/zsh -ex

# Read config.sh
. $(dirname $0)/../config.sh

snap_align () {
    org=$1
    ref=$2
    if [[ ! -s $currout/snap/$org.count ]];
    then
      mydate
      echo -n "Running SNAP against $org reference ... "
      mkdir -p $currout/snap
      pushd $currout/snap

      if [[ ${filepath: -3} == ".gz" ]];
      then
        readpath="zcat ${filepath}"
      elif [[ ${filepath: -4} == ".bz2" ]];
      then
        readpath="lbzcat ${filepath}"
      else
        readpath="cat $filepath"
      fi

      eval nice -n $nice /usr/bin/time $readpath | $SNAPBIN \
        single $ref/snap -fastq - -mrl 40 -C-- -t $THREADS -b -o $org.sam &> $org.log

      if [ `grep -vc "^@" $org.sam` -eq 0 ];
      then
        echo "0" > $org.count
      else
        samtools view -Sb -F 0x4 $org.sam > $org.bam
        samtools flagstat $org.bam | head -1 | cut -f1 -d' ' > $org.count
      fi
      rm $org.sam
      popd
      echo "Done."
    fi
}

star_align () {
    org=$1
    ref=$2
    if [[ ! -s $currout/star/$org.count ]];
    then
      mydate
      echo -n "Running STAR against $org reference ... "
      mkdir -p $currout/star/$org
      pushd $currout/star/$org
      eval nice -n $nice /usr/bin/time $STARBIN \
        --genomeDir $ref/star \
        --readFilesIn $readpath \
        --runThreadN $THREADS \
        > /dev/null
      if [ `grep "Uniquely mapped reads number" Log.final.out | cut -f2` -eq 0 ]
      then
        echo "0" > ../$org.count
      else
        samtools view -Su -F 0x4 Aligned.out.sam > $org.bam
        samtools flagstat $org.bam | head -1 | cut -f1 -d' ' > ../$org.count
        lbzip2 $org.bam
      fi
      rm Aligned.out.sam
      popd
      echo "Done."
    fi
}

bowtie2_align () {
    org=$1
    ref=$2
    if [[ ! -s $currout/bowtie2/$org.count ]];
    then
      mydate
      echo -n "Running Bowtie2 against $org reference ... "
      mkdir -p $currout/bowtie2
      pushd $currout/bowtie2
      export BOWTIE2_INDEXES=$ref/bowtie2
      eval nice -n $nice /usr/bin/time bowtie2 \
        --no-unal -p $THREADS -x genome -U $readpath -S $org.sam &> $org.log
      #if grep -q "0.00% overall alignment rate" $org.log
      #then
      #  echo "0" > ../$org.count
      #else
      #  samtools view -Sb -F 0x4 $org.sam > $org.bam
      #  samtools flagstat $org.bam | head -1 | cut -f1 -d' ' > $org.count
      #fi
      #rm $org.sam

      n1=$(sed '4q;d' $org.log | cut -d '(' -f1)
      n2=$(sed '5q;d' $org.log | cut -d '(' -f1)
      echo $((${n1#0}+${n2#0})) > ../$org.count

      popd
      echo "Done."
    fi
}

bwa_align () {
    org=$1
    ref=$2
    if [[ ! -s $currout/bwa/$org.bam ]];
    then
      mydate
      echo -n "Running BWA against $org reference ... "
      mkdir -p $currout/bwa
      pushd $currout/bwa
      eval bwa aln -t $THREADS $ref/bwa/meta-microbe.fasta $readpath > out.sai
      eval nice -n $nice /usr/bin/time bwa \
        samse $ref/bwa/meta-microbe.fasta out.sai \
        $readpath 2> $org.log | samtools view -Sb -F 0x4 - > $org.bam
      samtools flagstat $org.bam | head -1 | cut -f1 -d' ' > $org.count
      rm out.sai
      popd
      echo "Done."
    fi
}

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
  currouts=""
  samplename=$(basename $experimentlist)
  outputdir="./map-results/${samplename}"
  mkdir -p $outputdir
  cp $experimentlist $outputdir
  source $experimentlist #Gives us species and samplelist

  hostrefdir=$REFBASE/$species

  for filepath in $samplelist; do
    if [[ -z ${filepath//[[:blank:]]/} ]]
    then
      continue
    fi

    nice="0"
    filewoext=$(basename $filepath)
    file=${filewoext%%.*}

    if [[ ${filepath: -7} == ".tar.gz" ]];
    then
      echo ".tar.gz formats are not yet supported, see Jason"
      exit -1
    elif [[ ${filepath: -3} == ".gz" ]];
    then
      readpath="<(zcat ${filepath})"
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
    currouts="$currouts $currout"
    mkdir -p $currout
    echo "##################################################################"
    mydate
    echo "Processing file $file"
    if [[ ! -s $filepath ]];
    then
      echo "ERROR: $filepath Does not exist!!"
      exit -1
    fi

    #bowtie2_align gfp $REFBASE/genes/gfp
    #snap_align gfp $REFBASE/genes/gfp

    ################################ HOST ##########################
    if [[ ! -s $currout/star/$species.count ]];
    then
      mydate
      echo -n "Running STAR against host reference ... "
      mkdir -p $currout/star/$species
      pushd $currout/star/$species
      eval nice -n $nice /usr/bin/time $STARBIN \
        --genomeDir $hostrefdir/STAR \
        --readFilesIn $readpath \
        --runThreadN $THREADS \
        --sjdbGTFfile $hostrefdir/genes.gtf \
        --outSAMtype BAM Unsorted \
        --genomeLoad LoadAndKeep \
        > /dev/null

      echo "Done."
      mydate
      echo -n "Filtering STAR host alignments... "

      #samtools view -Sb -F 0x4 Aligned.out.sam > Aligned.out.bam
      samtools flagstat Aligned.out.bam | head -1 | cut -f1 -d' ' > ../$species.count
      #samtools sort Aligned.out.bam Aligned.sort.bam
      #samtools index Aligned.sort.bam
      ln -s Aligned.out.bam Aligned.filt.bam # kludge

      popd
      echo "Done."
    fi

    #if [[ ! -s $currout/sf/$species/quant.sf ]];
    #then
      #mydate
      #echo -n "Running Sailfish against host reference ... "
      #mkdir -p $currout/sf/$species
      #pushd $currout/sf/$species
      #export LD_LIBRARY_PATH=$SAILFISHLIB
      #eval nice -n $nice /usr/bin/time $SAILFISHBIN \
        #quant -i $hostrefdir/Sailfish \
        #-l "T=SE:S=U" \
        #-r $readpath \
        #-p $THREADS \
        #-o . &> out.log
      #popd
      #echo "Done."
    #fi

    #if [[ ! -s $currout/sf/$species/genequant.sf ]];
    #then
      #mydate
      #echo -n "Aggregating transcripts to genes ... "
      #mkdir -p $currout/sf/$species
      #pushd $currout/sf/$species
      #genesum -e quant.sf -k gene_name -g $hostrefdir/genes.gtf -o genequant.sf
      #popd
      #echo "Done."
    #fi

    if [[ ! -e $currout/diversity.count ]];
    then
      mydate 
      echo -n "Calculating unique reads ... "
      eval /usr/bin/time sed -n '2~4p' $readpath | python main-scripts/count_unique.py > $currout/diversity.count
      echo "Done."
    fi

    echo "##################################################################"

  done # over files sample-list
  mydate 
  echo -n "Counting reads using HTSeq-count ... "
  eval parallel --gnu -j15 main-scripts/htseq.sh {} $species $hostrefdir ::: $currouts
  echo "Done."

  mydate 
  echo -n "Post processing ribosomal reads ... "
  eval OMP_NUM_THREADS=1 julia misc-scripts/ribo.jl $species $hostrefdir $currouts
  echo "Done."
done # over arguments

mydate
echo ""

