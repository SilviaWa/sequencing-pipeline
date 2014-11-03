#!/usr/bin/env julia
include("utils.jl")

using PyCall
@pyimport matplotlib as mpl
mpl.use("Agg")
@pyimport pylab

if length(ARGS) < 1
    println("Correct Usage:")
    println("plot_subsample <counts_file> [<count_file>]")
    println("where you list all the count files (generated by")
    println("sum.jl) you wish to plot against each other")
end

function plot_exps(exps)
    datasets = map(x->(clean(x),sortrows(readcsv(x)[2:end,:])), exps)
    run(`mkdir -p $(joinpath(dirname(exps[1]), "out"))`)
    for (thresh,ind) in zip(["fpkm-0","fpkm-1", "fpkm-10", "reads-0", "reads-3", "reads-10"], [4,5,6,7,8,9])
        pylab.figure()
        println("Working on $thresh...")
        for (name,data) in datasets
            println("...Plotting $name")
            reads = data[:,2]
            y = data[:,ind]
            pylab.plot(reads,y,"-o",markersize=10,label=name,alpha=0.8)
        end
        pylab.grid()
        pylab.xlabel("Reads")
        pylab.ylabel("Human genes")
        pylab.legend(loc="best",fontsize=8)
        pylab.title("$thresh")
        x1,x2,y1,y2 = pylab.axis()
        pylab.axis((x1,x2,0,y2))

        clean_exps = join(map(x->split(clean(x),"-")[end],exps), "-")
        path = joinpath(dirname(exps[1]), "out", "$thresh-$clean_exps.png")
        println("Saving fig at $path")
        pylab.savefig(path)
    end
end

plot_exps(ARGS)
