using HDF5,JLD

fname = ARGS[1]

if isfile(fname)
    fid = open(fname)
else
    error("Not a valid file input!")
end

@load fname idset nameset biotypes idbiotype namebiotype id2name name2id exoncount
