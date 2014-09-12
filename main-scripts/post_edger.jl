using Gadfly
using DataFrames

if length(ARGS)!=1 || !isfile(ARGS[1])
    warn("Need <experiment file> to be first argument")
    exit(-1)
end

bname = basename(ARGS[1])
#apath = joinpath("analysis",bname)
epath = joinpath("analysis",bname,"edger")

print("Reading data in...")
desets = [fname=>readtable(joinpath(epath,fname))
            for fname in filter(x->ismatch(r"edger.*.csv",x),readdir(epath))]
println("Done.")

print("Making plots...")
makehist(data, title, col) = plot(data, x=col, Scale.x_continuous(minvalue=0.0, maxvalue=1.0),
                                    Guide.title(title), Geom.histogram(minbincount=20))
makesmear(data, title) = plot(data, x="logCPM", y="logFC", Theme(default_point_size=0.1mm),
                                    Guide.title(title), Geom.point)

pvals = hstack([makehist(y,x,"PValue") for (x,y) in desets]...)
fdrs = hstack([makehist(y,x,"FDR") for (x,y) in desets]...)
smeard = vcat([(z=copy(y);z[:comp]=x;z) for (x,y) in desets]...)
smears = plot(smeard, x="logCPM",y="logFC", xgroup="comp", Theme(default_point_size=0.1mm), Geom.subplot_grid(Geom.point))
println("Done.")

print("Saving plots...")
draw(PNG(joinpath(epath,"pvalues.png"), 12inch, 3inch), pvals)
draw(PNG(joinpath(epath,"fdrs.png"), 12inch, 3inch), fdrs)
draw(PNG(joinpath(epath,"smears.png"), 12inch, 3inch), smears)
println("Done.")


    
