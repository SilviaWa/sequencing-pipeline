using HDF5,JLD

fname = ARGS[1]

if isfile(fname)
    fid = open(fname)
else
    error("Not a valid file input!")
end

idset = Set{ASCIIString}() 
nameset = Set{ASCIIString}() 
biotypes = Set{ASCIIString}()

idbiotype = Dict{ASCIIString,ASCIIString}()
namebiotype = Dict{ASCIIString,ASCIIString}()

id2name = Dict{ASCIIString,ASCIIString}()
name2id = Dict{ASCIIString,ASCIIString}()

exoncount = Dict{ASCIIString,Int}()

print("0...")
for (i,line) in enumerate(eachline(fid))
    if beginswith(line, '#')
        continue
    end
    #Update Overall gene_biotype
    name = match(r"gene_name \"([^\"]*)\"", line).captures[1]
    id = match(r"gene_id \"([\w\-\.]*)\"", line).captures[1]
    if beginswith(id, "ERCC-0")
        biotype = "ERCC"
    else
        biotype = match(r"gene_biotype \"([\w\-\.]*)\"", line).captures[1]
    end

    push!(biotypes, biotype)
    push!(nameset, name)
    push!(idset, id)

    namebiotype[name] = biotype
    idbiotype[id] = biotype

    name2id[name]=id
    id2name[id]=name

    exoncount[id] = get(exoncount, id, 0)+1

    if i % 10000 == 0
        print("\r")
        print("$i...")
    end
end
close(fid)
println("Done")

#Write all these to a file
outdir = joinpath(dirname(fname), "gtfdata")

jldopen(outdir*".jld", "w") do file
    @write file idset
    @write file nameset
    @write file biotypes
    @write file idbiotype
    @write file namebiotype
    @write file id2name
    @write file name2id
    @write file exoncount
end

#mkdir(outdir)

#macro mywrite(val)
    #:(serialize(open(joinpath(outdir,$(string(val))),"w"), $val))
#end

#@mywrite(idset)
#@mywrite(nameset)
#@mywrite(biotypes)
#@mywrite(idbiotype)
#@mywrite(namebiotype)
#@mywrite(id2name)
#@mywrite(name2id)
#@mywrite(exoncount)
