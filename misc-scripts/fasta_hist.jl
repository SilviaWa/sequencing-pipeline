using FastaIO
#fname = "transcriptsw.fa"
fname = ARGS[1]

fmap = Dict{ASCIIString,Int}()
FastaReader(fname) do fr
    for (desc, seq) in fr
        fmap[desc] = length(seq)
    end
end

k = collect(keys(fmap))
v = collect(values(fmap))
histvals = hist(v)

println(histvals)

lens = sort(v, rev=true)
println(lens[1:10])
println(lens[end-10:end])

