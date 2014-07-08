#!/usr/bin/python3

# Obtained from superuser.com/questions/127786 Thanks Dennis Williamson!
import os, sys

if len(sys.argv) != 2:
    print(sys.argv[0] + ": Invalid number of arguments.")
    print ("Usage: " + sys.argv[0] + " filename")
    print ("to remove partial lines from the end of the file")
    exit(2)

file = sys.argv[1]
count = 0

with open(file,'r+b', buffering=0) as f:
    f.seek(0, os.SEEK_END)
    end = f.tell()
    while f.tell() > 0:
        f.seek(-1, os.SEEK_CUR)
        #print(f.tell())
        char = f.read(1)
        if char != b'\n' and f.tell() == end:
            print ("No change: file does not end with a newline")
            exit(1)
        if char == b'\n':
            count += 1
        if char == b'@':
            f.seek(-1, os.SEEK_CUR)
            f.truncate()
            print ("Removed " + str(count) + " lines from end of file")
            exit(0)
        f.seek(-1, os.SEEK_CUR)

if count < number + 1:
    print("No change: requested removal would leave empty file")
    exit(3)
