import matplotlib as mp
mp.use('Agg')
import scipy.stats as sy
import numpy as np
import pandas as pd
import matplotlib.pyplot as pp

# Syntax: scatter.py 'elist' /path/to/key.csv

# Reading the key file for the groups

kdata = pd.read_csv(sys.argv[2],header=None)
samples = np.array(kdata[0])
keys = np.array(kdata[1])

# Reading the HDF store for the gene counts

h5path = 'analysis/'+sys.argv[1]+'/'+sys.argv[1]+'.h5'
store = pd.HDFStore(h5path)
gdata = store['counts']['Lgr5'].to_dict()
store.close()

gfp=[]
lgr5=[]

# Reading the GFP counts from the .count files from all the sample directories

for sample in samples:
        gfpfile = "map-results/elist/" + sample + "/gfp.count"
        f = open(gfpfile)
        gfp.append(int(f.readline()))
        f.close()
        lgr5.append(gdata[sample])

# Appending as [samples;gene1;gene2;group]
samples = np.append([samples],[lgr5],axis=0)
samples = np.append(samples,[gfp],axis=0)
samples = np.append(samples,[keys],axis=0)

df = pd.DataFrame.from_records(np.transpose(samples))

# Grouping the matrix by the 'type' or 'group' column
grps = list(df.groupby(3))

c = ['c','m','k']
p=0

# Linear regression and plots

for g in grps:
        y = np.array(g[1][1])
        x = np.array(g[1][2])
        sc = pp.scatter(x,y,c=c[p],edgecolor='None')
        slope, intercept, r_value, p_value, std_err = sy.linregress(x,y)
        line = slope*x + intercept
        pp.plot(x,line,c[p]+'-',label=g[0]+' (p-value:'+str(round(p_value,4))+',
 r-value:'+str(round(r_value,4))+')')
        p=p+1

pp.grid()
pp.legend(loc='upper right',prop={'size':12})
pp.setp(sc,edgecolors='None')
pp.xlabel('GFP count', fontsize=14)
pp.ylabel('LGR5 count', fontsize=14)
pp.suptitle('GFP-LGR5 correlation', fontsize=18)
pp.savefig('scatter.png')

# Writing gene expression data to csv
df.to_csv('genes.csv',index_label=False,index=False,header=False)