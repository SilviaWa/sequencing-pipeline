#!/usr/bin/env python
import os,sys
from collections import Counter
import numpy as np

import matplotlib as mpl
mpl.use('Agg')
import pylab as p

USAGE_STRING = """Usage: 
python plot_hists.py <data_dir> [<data_dir>]
    <data_dir> - Location where counts file is contained 
                 (which is produced by map.sh).

This will create a plot called plot.png in the current folder.
"""

if len(sys.argv) < 2:
    print(USAGE_STRING)
    sys.exit()

sets = []
for fname in sys.argv[1:]:
    counts = []
    for line in open(os.path.join(fname, 'star', 'human', 'htseq.0.list')):
        counts.append(int(line.split()[1]))
    sets.append(np.array(counts))

for path,data in zip(sys.argv[1:], sets):
    p.hist(data, histtype='step', bins=np.r_[1:20], alpha=0.8, label=path.split('/')[1], log=True)

p.legend(fontsize=8,loc='best')
p.xlabel('Number of reads mapped to a gene')
p.ylabel('Number of genes with this many reads')
p.title('Htseq read count histogram with %s reads' % (path.split('/')[2]))
p.savefig('plot.png')
