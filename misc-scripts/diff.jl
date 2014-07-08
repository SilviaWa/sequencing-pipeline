#!/usr/bin/env julia
include("../main-scripts/utils.jl")

using DataFrames

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

jk1 = load_codelink(ARGS[1])
jk2 = load_codelink(ARGS[2])
rz1 = load_codelink(ARGS[3])
rz2 = load_codelink(ARGS[4])
