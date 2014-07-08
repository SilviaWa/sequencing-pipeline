import os,sys
from collections import Counter

USAGE_STRING = """Usage: 
python plot_ercc.py <data_dir> 
    <data_dir> - Location where counts file is contained 
                 (which is produced by map.sh).

This will create a plot called plot.png in the data_dir folder.
"""

if len(sys.argv) != 2:
    print(USAGE_STRING)
    sys.exit()

os.chdir(sys.argv[1])
cwd = os.path.abspath('.')
outname = os.path.basename(cwd)

true = {}
for line in open('/mnt/datab/refs/igenomes/ercc/cms_095046.txt'):
    if not line.startswith('Re-so'):
        temp = line.split()
        true[temp[1]] = float(temp[3])

print(os.path.abspath('.'))
counts = {}
for line in open('ercc.counts'):
    temp = line.split()
    counts[temp[1]] = float(temp[0])

import matplotlib as mpl
mpl.use('Agg')
import pylab as p

vector_true = []
vector_count = []
for key in counts.keys():
    vector_true.append(true[key])
    vector_count.append(counts[key])

missed = []
for key in true.keys():
    if key not in counts:
        missed.append(true[key])
counter = Counter(missed)

p.loglog(vector_true, vector_count, 'k.', markersize=10)
flag = True
for conc, num in counter.iteritems():
    if flag:
        p.loglog([conc, conc], [10**(num-1),0.1], 'r', linewidth=2, label='Missed Transcript')
        flag = False
    else:
        p.loglog([conc, conc], [10**(num-1),0.1], 'r', linewidth=2)

p.legend(loc='lower right')
p.xlabel('True concentration before dilution (attomoles/uL)')
p.ylabel('Observed counts')
p.title(cwd)
p.grid(True)

p.savefig('plot.png')
p.savefig('plot.pdf')
