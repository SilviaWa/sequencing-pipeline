using FastaIO

function read_buf(fname::ASCIIString, copybuf::Bool)
    fsize = filesize(fname)
    fid = open(fname)
    line = 0
    reads = 0
    bufsize = 4096
    buf = zeros(Uint8, bufsize)
    mydata = zeros(Uint8, bufsize)
    while position(fid) < (fsize-bufsize)
        read(fid, buf)
        if copybuf
            mydata = copy(buf)
        end
        for c in buf
            if c == uint8('\n')
                line+=1 
                if (line-1)%4 == 0
                    reads+=1
                end
            end
        end
    end
    print("buffered: ")
end

function read_native(fname)
    fid = open(fname)
    count = 0
    for (i,seq) in enumerate(eachline(fid))
        if (i-1)%4 == 0
            count += 1
        end
    end
    close(fid)
    print("eachline: ")
end

#fname = "/mnt/datab/DLVR2Chapkin/test-24.med.fastq" 
fname = "/mnt/datab/manasvi-stem-010113/255neg100ng_RNA_GATCAG_R1.fastq"
@time read_buf(fname, false)
#@time read_buf(fname, false)
#@time read_buf(fname, true)
#@time read_buf(fname, true)
#@time read_native(fname)
#@time read_native(fname)
#@time readall(`wc -l $fname`)
#@time readall(`wc -l $fname`)
