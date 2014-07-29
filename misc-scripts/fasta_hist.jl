using FastaIO
#fname = "transcriptsw.fa"
fname = ARGS[1]

fmap = Dict{ASCIIString,Int}()
FastaReader(fname) do fr
    for (desc, seq) in fr
        fmap[desc] = length(seq)
    end
end

vals = collect(values(fmap))
histvals = hist(vals)

print(histvals)

