#!/usr/bin/python
import sys, os
import pandas as pa
import subprocess as sb
from utils import *

# Grab experiment list file (just for name)
if len(sys.argv) < 2 or len(sys.argv) > 3 or not os.path.isfile(sys.argv[1]):
    print("""Proper usage:
        main-scripts/summary.py <experiment-file> [metadata-sample-key.csv]
        where metadata-sample-key.csv is a csv with the sample names as
        the first column and additional information of interest as
        columns after that.""")
    sys.exit(-1)

if len(sys.argv) == 3:
    key = pa.read_csv(sys.argv[2], index_col='sample')
    key.index = pa.Index(map(str,key.index))
else:
    key = pa.DataFrame()

batchname = os.path.basename(sys.argv[1])

batchroot = os.path.join('map-results',batchname)
if not os.path.isdir(batchroot):
    print("Not valid directory: {}".format(batchroot))
    sys.exit(-1)

def get_count(fname, org=None):
    return file_counts(collect(batchroot, fname, org))

species, samples = parse_efile(sys.argv[1])

print("Grabbing {}'s files".format(batchname))
summary_list = [
    ('total-reads', count_reads_fnames(samples))
    ,('uniq-reads', get_count('diversity.count'))
    ,('{}-reads'.format(species), get_count('{}.count'.format(species)))
    ,('{}-uniq'.format(species), get_star(batchroot, 'Uniquely mapped reads number', species))
    ,('{}-multi'.format(species), get_star(batchroot, 'Number of reads mapped to multiple loci',species))
    ,('htseq-0-genes', get_count('htseq.0.count',species))
    ,('htseq-3-genes', get_count('htseq.3.count',species))
    ,('htseq-10-genes', get_count('htseq.10.count',species))
    ]

try:
    os.makedirs('analysis/{}'.format(batchname))
except:
    pass

keys, series = zip(*summary_list)
summary_df = pa.DataFrame(dict(summary_list), columns=keys)
summary_df = summary_df.dropna(axis=1, how='all')
if key.empty:
    tab = summary_df
else:
    tab = pa.merge(key,summary_df, left_index=True, right_index=True)
tab.to_csv('analysis/{}/{}-summary.csv'.format(batchname, batchname), index_label="sample_id")

def get_data(batchroot, species, data_name, index_col=0, sep='\t', gen_df=None):
    datafiles = collect(batchroot, data_name, species)
    if gen_df == None:
        datalist = [pa.read_csv(fname, index_col=index_col, sep=sep, header=None) 
                for sampleid, fname in datafiles.iteritems()]
    else:
        datalist = [gen_df(fname) for sampleid, fname in datafiles.iteritems()]
    for tab in datalist:
        tab['index'] = tab.index
        tab.drop_duplicates(subset='index', inplace=True)
        del tab['index']
    data = pa.concat(datalist,axis=1, ignore_index=True)
    data.columns = datafiles.keys()
    return data.transpose()

final_count = get_data(batchroot, species, 'htseq.list')

final_count.to_csv('analysis/{}/{}-count.csv'.format(batchname,batchname), index_label="sample_id")
final_count.T.to_csv('analysis/{}/{}-count.T.csv'.format(batchname,batchname), index_label="sample_id")

fid = pa.HDFStore('analysis/{}/{}.h5'.format(batchname,batchname), complib='blosc', complevel=9)
fid['counts'] = final_count
fid['key'] = key
fid.close()

