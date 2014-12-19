import csv
import os
import sys
import subprocess

def read_csv():
  gse = "";
  with open(sys.argv[1]) as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
      for gsm in row:
      	if gsm[:3]=='GSE':
      		gse = gsm;
      		if not os.path.exists(gsm): 
			subprocess.call("mkdir %s" % gse, shell=True)
      			print(gse+":")

	else:
		subprocess.call("mkdir %s" % gse+"/"+gsm, shell=True)
		cmd = "edirect/esearch -db sra -query " + gsm + "| edirect/efetc
h --format runinfo | cut -d ',' -f 1 | grep SRR |  xargs sratools/bin/fastq-dump
 --bzip2 -O "+ gse+"/"+gsm
		subprocess.call(cmd, shell=True)
		print(gsm+":")

if __name__ == "__main__":
  read_csv()
