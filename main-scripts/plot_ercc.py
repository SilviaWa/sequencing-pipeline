import os
import sys
import pandas as pa

import matplotlib as mpl
mpl.use('Agg')
import pylab as p

from collections import Counter

USAGE_STRING = """Usage:
python plot_ercc.py <data_loc>
    <data_loc> - Location where counts HDF5 file is contained
                 (which is produced by summary.py).

This will create plots called <sample>.png in the ercc folder.
"""

if len(sys.argv) != 2:
    print(USAGE_STRING)
    sys.exit(-1)

if not os.path.exists(sys.argv[1]):
    print("File " + sys.argv[1] + " not found")
    print(USAGE_STRING)
    sys.exit(-1)

WORKDIR = os.path.join('analysis', os.path.basename(sys.argv[1]))
OUTDIR = os.path.join(WORKDIR, 'ercc')
DATALOC = os.path.join(WORKDIR, os.path.basename(sys.argv[1])+'.h5')

try:
    os.mkdir(OUTDIR)
except:
    pass

true = {}
for line in open('/mnt/datab/refs/ercc/cms_095046.txt'):
    if not line.startswith('Re-so'):
        temp = line.split()
        true[temp[1]] = float(temp[3])

trueconc = pa.Series(true).sort_index()
counts = pa.HDFStore(DATALOC)['ercc'].T.sort_index()


def makeplot(fname, ground, sample):
    p.close('all')
    p.loglog(ground, sample, 'k.', markersize=10)

    p.legend(loc='lower right')
    p.xlabel('True concentration before dilution (attomoles/uL)')
    p.ylabel('Observed counts')
    p.title(fname)  # check
    p.grid(True)

    p.savefig(os.path.join(OUTDIR, fname+'.png'))
    # p.savefig(os.path.join(OUTDIR, fname+'.pdf'))

for sample in counts:
    makeplot(sample, trueconc, counts[sample].clip_lower(1e-2))
