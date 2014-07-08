import os, sys
import re
import subprocess as sb
import pandas as pa

def collect(startroot, fname, organism=None):
    datafiles = {}
    for root,dirs,files in os.walk(startroot, followlinks=True):
        if organism is None:
            if os.path.exists(os.path.join(root,fname)):
                sampleid = root.split('/')[2]
                datafiles[sampleid] = os.path.join(root,fname)
        else:
            if os.path.exists(os.path.join(root,fname)) and root.find(organism)!=-1:
                sampleid = root.split('/')[2]
                datafiles[sampleid] = os.path.join(root,fname)
    N = len(datafiles)
    print("Found {} {} files:".format(N, fname))
    return datafiles

def count_reads_fnames(fnames):
    return {os.path.basename(fname).split('.')[0]:count_reads_fname(fname) 
            for fname in fnames}
    
def count_reads_fname(fname):
    try:
        res = int(get_xattr(fname, 'user.numreadsv2'))
    except:
        res = int(count_reads(fname))
        set_xattr(fname, 'user.numreadsv2', res)
    return res

def file_counts(fnames):
    return pa.Series({k:int(open(v).read()) for k,v in fnames.iteritems()})

def search_files(fnames, query):
    return {k:search_file(v,query) for k,v in fnames.iteritems()}

def search_file(fname, query):
    return [line for line in open(fname).read().split('\n') if line.find(query)!=-1][0]

def process_star(results, double=False):
    conv = float if double else int
    return pa.Series({k:conv(re.sub(r'[^\d.]+','',v.split('\t')[1])) 
            for k,v in results.iteritems()})

def get_star(batchroot, query, organism):
    return process_star(search_files(collect(batchroot, 'Log.final.out', organism), query))

def count_reads(fname):
    fname = fname.strip()
    if fname[-3:] == 'bz2':
        reads = '<(lbzcat {})'.format(fname)
    elif fname[-2:] == 'gz':
        reads = '<(zcat {})'.format(fname)
    elif fname[-5:] == 'fastq' or fname[-3:] == 'txt':
        reads = fname
    else:
        sys.exit("Non supported extension: {}".format(fname))

    return int(sb.check_output('zsh -c "wc -l {}"'.format(reads), shell=True).split(' ')[0])/4

def get_xattr(fname, attr):
    assert os.path.isfile(fname)
    return sb.check_output('getfattr --absolute-names --only-values -n {} {}'.format(
        attr,fname), shell=True)

def set_xattr(fname, key, val):
    assert os.path.isfile(fname)
    sb.check_call('setfattr -n {} -v {} {}'.format(
        key, val, fname), shell=True)

def parse_efile(efile):
    """ 
    Parse experiment list file
    """
    assert os.path.isfile(efile)
    samples = sb.check_output('zsh -c "source {}; echo \$samplelist"'.format(
        efile), shell=True).split()
    species = sb.check_output('zsh -c "source {}; echo \$species"'.format(
        efile), shell=True).strip()
    return species, samples
