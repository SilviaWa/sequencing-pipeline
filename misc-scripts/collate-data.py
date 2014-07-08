#!/usr/bin/python
import sys, os
import numpy as np
import scipy as sp
import pandas as pa

# Grab experiment list file (just for name)
if len(sys.argv) != 2:
    print("Need experiment list file to know what to input!")
    sys.exit(-1)

batchname = os.path.basename(sys.argv[1])
print("Grabbing {}'s files".format(batchname))

batchroot = os.path.join('map-results',batchname)
if not os.path.isdir(batchroot):
    print("Not valid directory: {}".format(batchroot))
    sys.exit(-1)

# Find all htseq.list files
datafiles = {}
for root,dirs,files in os.walk(batchroot):
    if os.path.exists(os.path.join(root,'htseq.list')):
            sampleid = root.split('/')[2]
            datafiles[sampleid] = os.path.join(root,'htseq.list')

N = len(datafiles)
print("Found {} htseq.list files:".format(N))

# Read them all in
datalist = [pa.read_csv(fname, index_col=0, sep='\t') for sampleid, fname in datafiles.iteritems()]
data = pa.concat(datalist,axis=1)
data.columns = map(int, datafiles.keys())
key = pa.read_csv('karen-rnaseq-key.csv', index_col=0)
final = pa.concat([data.transpose(), key], axis=1)
print final.dtypes

final.to_csv('{}.csv'.format(batchname))
fid = pa.HDFStore('{}.h5'.format(batchname), complib='blosc', complevel=9)
fid['data'] = final
fid.close()

