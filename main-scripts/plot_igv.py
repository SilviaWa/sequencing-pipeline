import os,sys
import socket

USAGE_STRING = """Usage: 
python plot_igv.py <output_dir> <data_loc> <species>
    <output_dir> - where you want pictures saved to
    <data_loc> - Path to bam alignment file
    <species> - name of reference genome alignment was made against (hg19, mm10)
"""

if len(sys.argv) != 4:
    print(USAGE_STRING)
    sys.exit()

# number of plots to draw from the top and bottom of the fpkm file
NTOP = 10
NBOTTOM = 5
TIMEOUT = 20.0

cwd = os.path.abspath(sys.argv[1])
read_loc = os.path.abspath(sys.argv[2])
genome = sys.argv[3]

os.chdir(cwd)

genes = open('../genes.sorted', 'r').readlines()[1:]
genes = [x.strip().split() for x in (genes[:NTOP] + genes[-NBOTTOM:])]

def check(s, cmd):
    try:
        s.sendall(cmd+'\n')
        ret = s.recv(4096)
    except socket.timeout:
        sys.stderr.write('Cmd "%s" timed out"\n' % (cmd))
        return False
    if not ret.startswith('OK'):
        if not cmd.startswith('goto'):
            sys.exit('Failed to run cmd "%s", received response "%s"' % (cmd, ret))
        return False
    return True

#sys.stderr.write("Connecting to IGV browser\n")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(TIMEOUT)
s.connect(('127.0.0.1', 60151))
#sys.stderr.write("Connected.\n")
check(s, 'new')
check(s, 'snapshotDirectory %s' % cwd)
check(s, 'genome %s' % genome)
check(s, 'load %s' % read_loc)
check(s, 'collapse')

for gene,fpkm in genes:
    if check(s, 'goto %s' % gene):
        check(s, 'snapshot %s_%s.png' % (gene,fpkm))

s.close()

