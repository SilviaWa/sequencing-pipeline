#!/usr/bin/Rscript

args <- commandArgs(trailingOnly = TRUE)

if(length(args) != 1) {
  stop("Need an experiment list file.
        And ./analysis/<experiment-name>/cuffdiff must exist and 
        contain the full of output from a cuffdiff analysis.")
}

library(cummeRbund)

outdir <- paste(sep="/", "analysis", basename(args[1]))
datadir <- paste(sep="/", outdir, "cuffdiff")
cuff <- readCufflinks(datadir)

#disp <-dispersionPlot(genes(cuff))
#ggsave(paste(sep="/", outdir, "dispersion.png"))

#scv <-fpkmSCVPlot(genes(cuff))
#ggsave(paste(sep="/", outdir, "scv.pdf"))

csd <- csDensity(genes(cuff))
ggsave(paste(sep="/", outdir, "csda.pdf"))

csb <- csBoxplot(genes(cuff))
ggsave(paste(sep="/", outdir, "csba.pdf"))

#csd <- csDensity(genes(cuff), replicates=TRUE)
#ggsave(paste(sep="/", outdir, "csd.pdf"))

csb <- csBoxplot(genes(cuff), replicates=TRUE)
ggsave(paste(sep="/", outdir, "csb.pdf"))

#sm <- csScatterMatrix(genes(cuff))
#ggsave(paste(sep="/", outdir, "scatter.png"))

#smr <- csScatterMatrix(genes(cuff), replicates=TRUE)
#ggsave(paste(sep="/", outdir, "scatter_all.png"))

myDistHeat <-csDistHeat(genes(cuff))#,replicates=TRUE)
ggsave(paste(sep="/", outdir, "heat.pdf"))

vm <- csVolcanoMatrix(genes(cuff))
ggsave(paste(sep="/", outdir, "vm.png"))

mySigMat<-sigMatrix(cuff,level='genes',alpha=0.05)
ggsave(paste(sep="/", outdir, "sigmat.png"))


#system("convert -density 100 scatter.pdf scatter.png")
#v<-csVolcano(genes(cuff),"premature","mature", alpha=0.39, showSignificant=TRUE)
  #labs(x="Preterm", y="Full term", title=NULL) + 
  #theme(text = element_text(size=20, family="serif"))
