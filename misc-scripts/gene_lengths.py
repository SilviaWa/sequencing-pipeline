import sys
from collections import Counter

import pandas as pa


fid = open(sys.argv[1])
for i in range(5):
    fid.readline()

lengths = Counter()
c = 0

for line in fid:
    vals = line.split()
    if vals[2] == 'exon':
        ind = vals.index('gene_name')
        gene = vals[ind+1][1:-2]
        lengths[gene] += int(vals[4]) - int(vals[3])
        c += 1

print("Processed {} exons".format(c))
pa.Series(lengths).to_csv('grcm38_lengths.csv')
