"""
Author: Jason Knight
Date: January 2013

A bit of toying around with the idea of using zlib compression to determine if a read contained enough information to be worth mapping. Abandoned ... for now ... ;)

Use as follows:

python entro.py 100000 | sort -k1,1 | less
"""
import zlib
import sys
import random

fid = open('test.fastq', 'r')
record = []
try:
    N = int(sys.argv[1])
except:
    N = 10000
k = 20
thresh = 0.3

baselen = 500
base = list('A'*(baselen/4) + 'C'*(baselen/4) + 'G'*(baselen/4) + 'T'*(baselen/4))
random.shuffle(base)
base = ''.join(base)
basecomp = len(zlib.compress(base))

for i in range(N):
    fid.readline()
    seq = fid.readline()
    fid.readline()
    fid.readline()

    l = len(seq)
    if l < k:
        continue
    complen = len(zlib.compress(base+seq)) - basecomp
    ratio = complen / float(l)
    #if ratio < thresh:
    record.append((ratio, complen, l, seq))

#record = sorted(record, key=lambda x:x[0])
for row in record:
    print "%.2f %6d %6d %s" % (row[0], row[1], row[2], row[3][:70].strip())
