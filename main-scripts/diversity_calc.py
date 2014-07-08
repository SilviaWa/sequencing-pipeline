import sys, os
from collections import Counter
import matplotlib as mpl
mpl.use('Agg')
import pylab as p

USAGE_STR='''diversity_calc.py <outputdir> <name>
if file not supplied, then input is assumed to come 
from stdin.

If input is fastq, then you must filter all the other lines eg:
    sed -n '2~4p' myfile | calc_diversity.py

Output will be written in the current directory under the two filenames:
<file>_<num_total_reads>_hist
<file>_tophits

where <file> is the name of the file ('stdin' if stdin)
and <num_total_reads> is the total number of reads processed.
'''

if len(sys.argv) != 3:
    print USAGE_STR

outdir = os.path.abspath(sys.argv[1])
fname = sys.argv[2]

seqcts = Counter(sys.stdin)
total = sum(seqcts.values())

with open('%s/%s_tophits' % (outdir, fname),'w') as fidout:
    for seq,count in seqcts.most_common(20):
        fidout.write("%d\t%s\n" % (count, seq.strip()))

metacts = Counter(seqcts.values())
with open('%s/%s_hist' % (outdir, fname),'w') as fidout:
    fidout.write("%s\t%s\n" % ("Number of duplicates","Number of unique reads"))
    items = sorted(metacts.iteritems())
    for num,count in items:
        fidout.write("%d\t%d\n" % (num,count))

p.loglog(metacts.keys(), metacts.values(), 'ko')
p.xlabel("Number of duplicates")
p.ylabel("Number of unique reads at this duplication level")
p.savefig('{}/{}.png'.format(outdir,fname))
