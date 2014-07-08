#!/usr/bin/python
import sys, os
import re
import numpy as np
import scipy as sp
import pandas as pa
import subprocess as sb
import yaml

from utils import *

# Read the config file
with open('config.yaml','r') as config_file:
        config = yaml.load(config_file)
        config_file.close()

# Grab experiment list file (just for sample names)
if len(sys.argv) != 3 or not os.path.isfile(sys.argv[1]):
    print("""Proper usage:
        main-scripts/summary.py <experiment-file> [metadata-sample-key.csv]
        where metadata-sample-key.csv is a csv with the sample names as
        the first column and additional information of interest as
        columns after that.""")
    sys.exit(-1)

# Key file giving groups to samples
key = pa.read_csv(sys.argv[2], index_col='sampleid')
batchname = os.path.basename(sys.argv[1])
species, samples = parse_efile(sys.argv[1])

# Grab all mapped bam files
bams = collect('map-results/{}'.format(batchname), 
    'Aligned.filt.bam') # STAR Reads currently
sample_key = {}
for sampid in key.index:
    res = [x for x in bams.values() if x.find(str(sampid))!=-1]
    assert len(res) == 1
    sample_key[sampid] = res[0]

g = key.groupby(config['GROUPS'])

gids = []
samples = []
for gid,group in g.groups.iteritems():
    gids.append(gid)
    samples.append(','.join(map(str, [sample_key[x] for x in group])))

refbase = config['REFBASE']+config[species]['ref']
gtf = refbase + '/Annotation/Genes/genes.gtf'
reffa = refbase + '/Sequence/WholeGenomeFasta/genome.fa'

if type(gids[0]) == str:
    labels = ','.join(gids)
else:
    labels = ','.join(['-'.join(map(str,x)) for x in gids])

outdir = './analysis/{}/cuffdiff'.format(batchname)
sb.check_call('mkdir -p {}'.format(outdir), shell=True)

cmd = 'cuffdiff -p 30 -o {} -b {} -L {} {} {}'.format(
        outdir, 
        reffa, 
        labels, 
        gtf, 
        ' '.join(samples)) 

print cmd
sb.check_call(cmd, shell=True)

