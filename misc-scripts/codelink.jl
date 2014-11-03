#!/usr/bin/env julia
include("utils.jl")

using DataFrames
using PyCall
@pyimport matplotlib as mpl
mpl.use("Agg")
@pyimport pylab as p

function load_codelink(fname)
    microdata = readtable(fname, separator='\t', nastrings=["","NULL"], skipstart=7)
    rename!(microdata, ["Annotation_OGS","Raw_intensity"], ["geneid", "microsignal"])
    ind = find((microdata[:geneid].!="") & 
                (microdata[:microsignal].>1e-3) & 
                !isna(microdata[:geneid]) &
                (microdata[:Quality_flag].=="G"))
    microdata = microdata[ind, [:geneid, :microsignal]]
    microdata = groupby(microdata, :geneid) |> :mean
    rename!(microdata, "microsignal_mean", "microsignal")
    return microdata
end

function load_seqdata(fname)
    seqdata = readtable(joinpath(fname, "clstar","human","genes.full"), 
                            separator='\t', 
                            header=false, 
                            colnames=["geneid","seqsignal"])
    seqdata = groupby(seqdata, :geneid) |> :mean
    rename!(seqdata, "seqsignal_mean", "seqsignal")
    seqdata = seqdata[:(seqsignal.>1e-3),:]
    return seqdata
end

function plot_scatter(fname, data1, data2, xlabel, ylabel)
    alldata = merge(data1, data2, :geneid)
    vec1 = vector(alldata[:, 2])
    vec2 = vector(alldata[:, 3])

    p.figure()
    p.loglog(vec1, vec2, "k.")
    for i=1:length(vec1)
        p.annotate(alldata[i,:geneid], xy=(alldata[i,2],alldata[i,3]),fontsize=6)
    end
    p.axis((min(vec1)*0.8, max(vec1)*1.2, min(vec2)*0.8, max(vec2)*1.2))
    p.xlabel(xlabel)
    p.ylabel(ylabel)
    pearson = cor(vec1,vec2)
    spearman = cor_spearman(vec1, vec2)
    title = @sprintf "\nPearson: %.3f, Spearman: %.3f" pearson spearman
    p.title(clean(fname)*title, fontsize=10)
    println(fname)
    p.savefig(joinpath("imgs","codelinks",fname))
end

if length(ARGS) < 2 || !(ARGS[1]=="auto" || ARGS[1]=="compare" || ARGS[1]=="manual")
    println("Correct Usage:")
    println("codelink.jl auto <codelink.csv> [<codelink.csv>...]")
    println("or")
    println("codelink.jl compare <seqfolder> <codelink.csv> [...]")
    println("or")
    println("codelink.jl manual <type>:<location> <type>:<location>")
    println("eg:")
    println("codelink.jl manual micro:myfolder/myfile seq:myfolder")
elseif ARGS[1] == "auto"
    key = readtable("super-key.csv", cleannames=true)
    codelink = load_codelink(ARGS[2])
    for fname in ARGS[2:end]
        println("Processing $fname...")
        subject, soln, proto = split(clean(fname),'-')

        trans_soln = ["later"=>"RNA Later", "denat"=>"Denaturation", "shield"=>"RNA Shield"]
        trans_proto = ["reg"=>"regular", "clean"=>"clean"]

        soln = trans_soln[soln]
        subject = uppercase(subject)
        proto = trans_proto[proto]

        selection = key[:((Subject.==$subject) & (Solution.==$soln) & (RNA_isolation.==$proto)), :]

        seqfnames = map(clean,selection[:file])
        seqdatas = [load_seqdata(joinpath("map-results","lampe-13",x)) for x in seqfnames]

        seqnames = [replace(join(matrix(
                selection[i,[:Subject,:Solution,:RNA_isolation,:Library]]),"-"), " ", "") 
                for i in 1:nrow(selection)]

        for (seqname, seqdata) in zip(seqnames, seqdatas)
            println("... plotting $seqname")
            plot_scatter("$seqname-$(clean(fname)).png", codelink, seqdata,
                "Microarray signal strength", "Sequencing FPKM")
        end
        println("Done.")
    end
elseif ARGS[1] == "compare"
    seqdata = load_seqdata(ARGS[2])
    for fname in ARGS[3:end]
        codelink = load_codelink(fname)
        println("Plotting $fname against $fname")
        plot_scatter("compare-$(clean(ARGS[2]))-$(clean(fname)).png", codelink, seqdata,
                "Microarray signal strength", "Sequencing FPKM")
    end
elseif ARGS[1] == "manual"
    labeler(x) = x == "micro" ? "Microarray signal strength" : "Sequencing FPKM"
    loader(x) = x == "micro" ? load_codelink : load_seqdata
    fname1,tag1 = split(ARGS[2],':')
    fname2,tag2 = split(ARGS[3],':')
    if tag1 == tag2
        label1 = labeler(tag1) * clean(fname1)
        label2 = labeler(tag2) * clean(fname2)
    else
        label1 = labeler(tag1) 
        label2 = labeler(tag2)
    end
    data1 = loader(tag1)(fname1)
    data2 = loader(tag2)(fname2)
    plot_scatter("$(clean(fname1))-$(clean(fname2)).png", data1, data2, label1, label2)
end
