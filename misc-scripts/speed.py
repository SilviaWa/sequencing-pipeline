import time

def read_native(fname):
    count = 0
    reads = 0
    for line in open(fname):
        count+=1
        if count%4==0:
            reads+=1
    print(reads)

fname = "/mnt/datab/DLVR2Chapkin/test-24.med.fastq" 
t1 = time.time()
read_native(fname)
print(time.time()-t1)
