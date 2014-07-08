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
    ,('ercc-reads', get_count('ercc.count'))
    ,('htseq-0-genes', get_count('htseq.0.count',species))
    ,('htseq-3-genes', get_count('htseq.3.count',species))
    ,('htseq-10-genes', get_count('htseq.10.count',species))
    ,('rpkm-0-genes', get_count('genes.count',species))
    ,('rpkm-1-genes', get_count('genes.1.count',species))
    ,('rpkm-10-genes', get_count('genes.10.count',species))
    #,('mito', get_count('mito.count'))
    #,('ribo', get_count('ribo.count'))
    #,('micro', get_count('micro.count'))
    #,('viral', get_count('viral.count'))
    #,('fungi', get_count('fungi.count'))
    #,('protozoa', get_count('protozoa.count'))
    ]

try:
    os.makedirs('analysis/{}'.format(batchname))
except:
    pass

keys, series = zip(*summary_list)
summary_df = pa.DataFrame(dict(summary_list), columns=keys)
summary_df = summary_df.dropna(axis=1, how='all')
tab = pa.merge(key,summary_df, left_index=True, right_index=True)
tab.to_csv('analysis/{}/{}-summary.csv'.format(batchname, batchname), index_label="sample_id")

def get_data(batchroot, species, data_name, index_col=0, sep='\t', gen_df=None):
    datafiles = collect(batchroot, data_name, species)
    if gen_df == None:
        datalist = [pa.read_csv(fname, index_col=index_col, sep=sep) 
                for sampleid, fname in datafiles.iteritems()]
    else:
        datalist = [gen_df(fname) for sampleid, fname in datafiles.iteritems()]
    for tab in datalist:
        tab['index'] = tab.index
        tab.drop_duplicates(cols='index', inplace=True)
        del tab['index']
    data = pa.concat(datalist,axis=1, ignore_index=True)
    #data.columns = map(int, datafiles.keys())
    data.columns = datafiles.keys()
    return data.transpose()

final_count = get_data(batchroot, species, 'htseq.list')
final_fpkm = get_data(batchroot, species, 'genes.full')

def ercc_df(fname):
    dat = {}
    for line in open(fname,'r'):
        count, erccid = line.strip().split()
        dat[erccid] = int(count)
    return(pa.DataFrame(pa.Series(dat)))

ercc_dat = get_data(batchroot, 'star', 'ercc.counts', gen_df=ercc_df)
ercc_dat.to_csv("analysis/{}/ercc.csv".format(batchname), index_label='sample_id')

final_count.to_csv('analysis/{}/{}-count.csv'.format(batchname,batchname), index_label="sample_id")
final_count.T.to_csv('analysis/{}/{}-count.T.csv'.format(batchname,batchname), index_label="sample_id")
final_fpkm.to_csv('analysis/{}/{}-fpkm.csv'.format(batchname,batchname), index_label="sample_id")
final_fpkm.T.to_csv('analysis/{}/{}-fpkm.T.csv'.format(batchname,batchname), index_label="sample_id")

fid = pa.HDFStore('analysis/{}/{}.h5'.format(batchname,batchname), complib='blosc', complevel=9)
fid['counts'] = final_count
fid['fpkm'] = final_fpkm
fid['ercc'] = ercc_dat
fid['key'] = key
fid.close()

#Some old code that I'm keeping around for simple analyses:
#bams = collect(batchroot, 'Aligned.filt.bam')
#data = {}
#for sid,fname in bams.iteritems():
    #temp = sb.check_output('samtools view {} | cut -f3 | uniq -c'.format(fname),
            #shell=True).split('\n')[:-1]
    #def proc(x):
        #num,spec = x.strip().split()
        #return (spec, int(num))
    #data[sid] = dict([proc(x) for x in temp])
#idf = pa.DataFrame(data).T
#df = pa.concat((key,idf), axis=1).fillna(0)
#dfavg = df.pivot_table(rows='time tissue a b'.split())
#df.to_csv('kolo.csv')
#dfavg.to_csv('kolo_mean.csv')
#sys.exit()

