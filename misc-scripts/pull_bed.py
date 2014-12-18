import sys
from collections import Counter

import pandas as pa


fid = open(sys.argv[1])

for line in fid:
    vals = line.split()
    ind = vals.index('gene_name')
    gene = vals[ind+1][1:-2]
    print("{}\t{}".format(gene,vals[-4]))

