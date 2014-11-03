#!/usr/bin/env julia

include("utils.jl")

function select_files()
    samples = read_experiment("lists/lampe-13")
    key = readcsv("sample-key.csv")

    #selector = (key[:, 2] .== "RZ") & (key[:,5].=="DGE") #& (key[:,3].=="Denaturation")
    #name = "rz-dge"
    
    #selector = ((key[:,5].=="DGE") | (key[:,5].=="Complete")) & (key[:,3].=="Denaturation")
    #name = "dge-complete-denat"

    #selector = ((key[:,5].=="DGE") | (key[:,5].=="Complete")) & (key[:,3].=="RNA Later")
    #name = "dge-complete-later"

    #selector = ((key[:,5].=="DGE") | (key[:,5].=="Complete")) & (key[:,3].=="RNA Shield")
    #name = "dge-complete-shield"

    #selector = ((key[:,5].=="DGE") | (key[:,5].=="Complete")) & (key[:,4].=="clean")
    #name = "dge-complete-clean"

    #selector = ((key[:,5].=="DGE") | (key[:,5].=="Complete")) & (key[:,4].=="regular")
    #name = "dge-complete-regular"
    
    ###########################

    #selector = (key[:,5].=="DGE") & (key[:,3].=="Denaturation")
    #name = "dge-denat"

    #selector = (key[:,5].=="DGE") & (key[:,3].=="RNA Later")
    #name = "dge-later"

    #selector = (key[:,5].=="DGE") & (key[:,3].=="RNA Shield")
    #name = "dge-shield"

    #selector = (key[:,5].=="DGE") & (key[:,4].=="clean")
    #name = "dge-clean"

    selector = (key[:,5].=="DGE") & (key[:,4].=="regular")
    name = "dge-regular"
    
    ###########################

    #selector = (key[:,5].=="DGE") & !(convert(BitArray{1},map(x->beginswith(x,"Stem"), key[:,2])))
    #name = "dge"

    #selector = (key[:,5].=="Complete") & !(convert(BitArray{1},map(x->beginswith(x,"Stem"), key[:,2])))
    #name = "complete"

    #println(key[selector,1])

    sampleids = map(int,key[selector,1])
    filtsamples = [samples[findfirst(x->int(basename(x)[8:9])==id,samples)] for id in sampleids]

    println("Samples for $name:")
    for (f,s) in zip(filtsamples, find(selector))
        println("$(basename(f)) : $(join(key[s,[2,3,4,5]],"-"))")
    end
    println("")

    total = count_all_reads(filtsamples)
    println("Total reads in filtered batch: $total")
    @time subsample(filtsamples, name)

    #TODO: What would be really nice is to take these sample names and go
    #ahead and generate an experiment file in lists/ with the names of all the
    #samples, although we either need to stop renaming them with the correct
    #number of reads or make this list after all is said and done.
end

function subsample(samples, name)
    total = count_all_reads(samples)
    desired = int([5,10,20,30,50] * 1e6)
    p_i = desired / total
    final_counts = copy(desired)*0

    dir = joinpath("/mnt/datab/DLVR2Chapkin/subsamples", name)
    run(`mkdir -p $dir`)
    out_files = map(x->open(joinpath(dir,"$x.fastq"), "w"), desired)

    progress = 0
    for (i,line) in enumerate(eachline(`cat $samples`))
        if (i-1) % 4 == 0
            samplers = find(rand() .< p_i)
            for ind in samplers
                final_counts[ind] += 1
            end
            progress += 1
            if progress % 1000000 == 0
                print("$(div(progress,1000000))M..")
            end
        end
        for ind in samplers
            write(out_files[ind], line)
        end
    end
    println("Done!")
    for fid in out_files
        close(fid)
    end
    for (d,c) in zip(desired, final_counts)
        mv(joinpath(dir,"$d.fastq"), joinpath(dir,"$c.fastq"))
        println("Wrote $c.fastq")
    end
end

function count_all_reads(samples)
    sum = 0
    for sample in samples
        sum += count_cache_reads(sample)
    end
    sum
end

function each_in_experiment(fname)
    samples = read_experiment(fname)
    for sample in samples
        subsample([sample], clean(sample))
    end
end

##########

#each_in_experiment("lists/lampe-13-stem")
select_files()
#subsample(read_experiment("lists/test-lampe-13"), "test")
