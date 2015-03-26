library(edgeR)

# From: http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
# So we can copy this script to where the analysis output is saved
thisFile <- function() {
        cmdArgs <- commandArgs(trailingOnly = FALSE)
        needle <- "--file="
        match <- grep(needle, cmdArgs)
        if (length(match) > 0) {
                # Rscript
                return(normalizePath(sub(needle, "", cmdArgs[match])))
        } else {
                # 'source'd via R console
                return(normalizePath(sys.frames()[[1]]$ofile))
        }
}

#args = c("lists/organoid","keys/organoid.csv")
args = c("lists/lampe-biopsy-ercc38","keys/lampe-biopsy-key.csv")

# Get counts file from analysis/fname/fname.T.csv
bname = basename(args[1]) 
fname = paste(bname,"-count.T.csv",sep='')
dat = read.csv(file.path("analysis",bname,fname), header = TRUE, row.names=1)

# Filter low count reads
keep = rowSums(cpm(dat) > 3) >= 3
counts = dat[keep,]

## Read in key file
key = read.csv(args[2], header=TRUE, row.names=1)

#############################################
## Create model comparison matrix with sample key
#############################################
# Lampe Biopsy main
sel = grepl("MT-.*", rownames(counts)) + grepl("ERCC-.*", rownames(counts)) + grepl("mt-.*", rownames(counts))
counts = counts[!sel,]
ename = "edger-2x2-paired-cross-norm"
factors = key[order(rownames(key)), c("idnum", "location", "tissue")]
factors$idnum = factor(factors$idnum)
# factors$treatment = relevel(factors$treatment, "placebo")
design = model.matrix(~idnum+location*tissue, data=factors)
#groups = factors$tissue
groups = factor(paste(key$tissue,key$location,sep='.'))
#############################################

counts = counts[,order(names(counts))]

########################
# run Pairwise analysis ...
########################
# y = DGEList(counts=counts, group=factors)
# y = calcNormFactors(y)
# y = estimateCommonDisp(y)
# y = estimateTagwiseDisp(y)

########################
# or run GLM analysis
########################
y = DGEList(counts=counts)
y = calcNormFactors(y)
y = estimateGLMCommonDisp(y, design)
y = estimateGLMTrendedDisp(y, design)
y = estimateGLMTagwiseDisp(y, design)
fit = glmFit(y, design)

## get counts for each group for outputting to summary spreadsheet
dfs = split.data.frame(t(counts), groups)
dfss = sapply(dfs, colMeans)

#group_names = levels(groups)
#group_names_means = sapply(group_names, function(x) paste("mean_",x,sep=""), USE.NAMES=FALSE)
#colnames(dfss) = group_names_means

#### Write results
run_analysis = function(outfile, contrast=NULL, coef=NULL) {
  # Pairwise test
    # lrt = exactTest(y)
  # GLM Test
    lrt = glmLRT(fit, contrast=contrast, coef=coef) 

  ot1 = topTags(lrt,n=nrow(counts),sort.by="PValue")$table
  #if (is.null(contrast)) {
    #sel = which(as.logical(contrast))
    #ot1 = merge(ot1, dfss[,sel], by=0)
  #} else {
    #ot1 = merge(ot1, dfss, by=0)
  #}
  ot1 = merge(ot1, dfss, by=0)
  write.csv(ot1,outfile,row.names=FALSE)
  #detags = rownames(topTags(lrt,n=20))
  print(outfile)
  
  if (!is.null(lrt$table$logFC)){
    detags = rownames(ot1)[ot1$FDR < 0.05]
    png(paste(outfile,".png",sep=""))
    plotSmear(lrt, de.tags=detags)
    abline(h=c(-2,2),col="blue")
    dev.off()
  }
  #print(cpm(y)[detags,])
  print(summary(decideTestsDGE(lrt, p=0.05, adjust="BH")))
  #print(summary(decideTestsDGE(lrt, p=0.05, adjust="none")))
}

system(paste("mkdir -p ",file.path("analysis",bname,ename)))
file.copy(thisFile(), file.path("analysis", bname, ename, "edger_script.R"))

meta_run = function(coef) {run_analysis(file.path("analysis",bname,ename,paste(colnames(design)[coef],".csv",sep="")),coef=coef)}

meta_run(dim(design)[2])
meta_run(dim(design)[2]-1)
meta_run(dim(design)[2]-2)

# Pairwise test
# run_analysis(file.path("analysis",bname,paste(ename,".csv",sep="")))

## output MA, MDS, etc.., plots
png(file.path("analysis",bname,ename,"edger-mds.png"))
p = plotMDS(y)
dev.off()

png(file.path("analysis",bname,ename,"edger-bcv.png"))
p = plotBCV(y)
dev.off()
