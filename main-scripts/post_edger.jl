using Gadfly
using Color
using DataFrames
using HDF5, JLD


function makehist(data, title, col) 
    width = 0.02
    x = 0:width:1.0
    _,y = hist(data[symbol(col)], x)
    #println(title, y)
    return plot(xmin=x[1:end-1], xmax=x[2:end], y=y, Scale.x_continuous(minvalue=0.0, maxvalue=1.0),
                                Guide.title(title), Guide.xlabel(col), Guide.ylabel("Number of Genes"), Geom.bar)
end

makesmear(data, title) = plot(data, x="logCPM", y="logFC", Theme(default_point_size=0.1mm), Guide.title(title), Geom.point)

function make_plots(epath)

    print("Reading data in...")
    desets = [fname=>readtable(joinpath(epath,fname))
                for fname in filter(x->ismatch(r"^edger.*.csv",x),readdir(epath))]
    println("Done.")
    print("Making plots...")

    pvals = hstack([makehist(y,x,"PValue") for (x,y) in desets]...)
    fdrs = hstack([makehist(y,x,"FDR") for (x,y) in desets]...)
    smeard = vcat([(z=copy(y);z[:comp]=x;z) for (x,y) in desets]...)
    smears = plot(smeard, x="logCPM",y="logFC", xgroup="comp", Theme(default_point_size=0.3mm,default_color=RGB(0,0,0),highlight_width=0mm), Geom.subplot_grid(Geom.point))
    println("Done.")

    print("Saving plots...")
    #draw(PNG(joinpath(epath,"pvalues.png"), 10inch, 4inch), pvals)
    #draw(PNG(joinpath(epath,"fdrs.png"), 10inch, 4inch), fdrs)
    draw(PNG(joinpath(epath,"smears.png"), 12inch, 3inch), smears)
    draw(PNG(joinpath(epath,"all.png"), 12inch, 5inch), vstack(pvals,fdrs))
    println("Done.")
end
    
function filt_ncrna(epath)
    fname = "/mnt/datab/refs/grcm38/gtfdata.jld"
    namebiotype = load(fname, "namebiotype")
    cats = Set(["pseudogene","TR_V_pseudogene","lincRNA","polymorphic_pseudogene","3prime_overlapping_ncrna","IG_V_pseudogene"])
    ncset = filter((x,y)->y in cats, namebiotype) |> keys |> collect |> Set

    desets = [fname=>readtable(joinpath(epath,fname))
                for fname in filter(x->ismatch(r"^edger.*.csv",x),readdir(epath))]

    for (fname,dat) in desets
        sel = Bool[x in ncset for x in dat[:Row_names]]
        ncdata = dat[sel, :]
        writetable(joinpath(epath,"lncrna-"*fname), ncdata)
    end
end

if length(ARGS)==1 && isfile(ARGS[1])
    bname = basename(directory)
    epath = joinpath("analysis",bname,"edger")
    make_plots(ARGS[1])
end
