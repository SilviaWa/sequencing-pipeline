#!/usr/bin/python
import matplotlib as mpl
mpl.use('Agg')
import pylab as p
import numpy as np
import scipy as sp
import scipy.stats as st
import bottleneck as bn
import os
import sys

# This file expects two paths to genes.sorted.full files
f1 = sys.argv[1]
f2 = sys.argv[2]

diff = 0
while f1[diff] == f2[diff]:
    diff +=1 
f1short = f1[diff:diff+5]
f2short = f2[diff:diff+5]

typelist = 'a40 f8'.split()
header = ['tracking_id',
 'FPKM']

mydtype = zip(header, typelist)

data1 = np.genfromtxt(f1, delimiter='\t', skip_header=1, dtype=mydtype)
data2 = np.genfromtxt(f2, delimiter='\t', skip_header=1, dtype=mydtype)

data1 = np.sort(data1)
data2 = np.sort(data2)

threshold = (data1['FPKM'] > 0) * (data2['FPKM'] > 0)
#threshold = (data1['Total_exon_reads'] > 0) + (data2['Total_exon_reads'] > 0)
#threshold = (data1['Total_exon_reads'] > 3) * (data2['Total_exon_reads'] > 3)

filt1 = data1[threshold]
filt2 = data2[threshold]

#TODO need to put these in the figure or save them to a file
v,pval = st.pearsonr(filt1['FPKM'], filt2['FPKM'])
print "Pearson: %f, p-value: %g" % (v,pval)
v,pval = st.spearmanr(filt1['FPKM'], filt2['FPKM'])
print "Spearman: %f, p-value: %g" % (v,pval)

temp1 = np.argsort(filt1['FPKM'])[::-1]
temp2 = np.argsort(filt2['FPKM'])[::-1]
decSort1 = temp1.argsort()
decSort2 = temp2.argsort()

p.figure(figsize=(15,10), dpi=90)

##### FPKM Histograms ##########
p.subplot(2,3,1)
p.hist(np.clip(np.log10(filt1['FPKM']), -5, np.infty)
        ,bins=100,log=True)
p.title('FPKM Histogram - %s' %f1short)
p.xlabel(f1short + ' log10(FPKM) frequency')
p.ylabel('No. of Genes')

p.subplot(2,3,2)
p.hist(np.clip(np.log10(filt2['FPKM']), -5, np.infty)
        ,bins=100,log=True)
p.title('FPKM Histogram - %s' %f2short)
p.xlabel(f1short + ' log10(FPKM) frequency')
p.ylabel('No. of Genes')
###########################

##### FPKM SCATTER ##########
bottom = 10**-2
p.subplot(2,3,3)
p.loglog(np.clip(filt1['FPKM'], bottom, np.infty), 
         np.clip(filt2['FPKM'], bottom, np.infty)
         ,'go', alpha=0.5)
p.title('FPKM Scatter Plot')
p.xlabel('log(' + f1short + ' FPKM)')
p.ylabel('log(' + f2short + ' FPKM)')
###########################

##### RANK SCATTER ##########
p.subplot(2,3,4)
p.plot(decSort1,decSort2,'ro', alpha=0.5)
p.title('0 and 0 - Rank vs. Rank')
p.xlabel(f1short)
p.ylabel(f2short)
p.axis('equal')
#p.show()
#sys.exit()
###########################

##### WINDOW DISTRIBUTION ##########
windows = decSort2[decSort1.argsort()] - np.arange(decSort2.size)
p.subplot(2,3,5)
p.plot(windows,'ro', alpha=0.5)
p.title('Rank Differences with standard deviations')
p.xlabel('Gene expression rank')
p.ylabel(f1short + '-' + f2short)

y = bn.move_std(windows, 10)
p.plot(y,'b')
p.plot(-y,'b')
###########################

##### VENN BUBBLES ##########
thresh1 = data1['FPKM'] > 0
thresh2 = data2['FPKM'] > 0

set1 = set(data1[thresh1]['tracking_id'])
set2 = set(data2[thresh2]['tracking_id'])

aandb = len(set1.intersection(set2))
a = len(set1.difference(set2))
b = len(set2.difference(set1))

print "aandb %d, a %d, b %d" % (aandb, a, b)
os.popen('./main-scripts/venn.py -f output.png %d %d %d "%s" "%s"' % (aandb,a,b,f1short,f2short))

p.subplot(2,3,6)
p.imshow(p.imread('output.png'))
p.title('Number of genes with non-zero FPKM read')
###########################


##### VENN SWEEP ##########
#thresholds = np.logspace(-2,2,200)
#aprop = np.empty_like(thresholds)
#bprop = np.empty_like(thresholds)

#for (i,),t in np.ndenumerate(thresholds):
    #thresh1 = data1['FPKM'] > t
    #thresh2 = data2['FPKM'] > t

    #set1 = set(data1[thresh1]['tracking_id'])
    #set2 = set(data2[thresh2]['tracking_id'])

    #aandb = len(set1.intersection(set2))
    #a = len(set1.difference(set2))
    #b = len(set2.difference(set1))

    #if aandb > 0:
        #aprop[i] = a/float(aandb)
        #bprop[i] = b/float(aandb)
    #else:
        #aprop[i],bprop[i] = 0,0
############################

####### VENN SWEEP PLOT ##########
#p.subplot(2,3,6)
#p.semilogx(thresholds, aprop, thresholds, bprop)
#p.grid('on')
#p.legend((f1short,f2short))
#p.title('Venn Diagram Proportions')
#p.xlabel('FPKM Threshold')
#p.ylabel('Proportion of unique genes to common genes')
###########################

# TODO should probably save this somewhere more specifically...
savename = '%s_v_%s.png' % (f1short,f2short)
print "Saving image to %s" % savename
p.savefig(savename)
