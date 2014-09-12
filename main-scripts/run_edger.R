library(edgeR)

args = commandArgs(trailing=TRUE)
args = c("lists/lampe-biopsy-ercc38","keys/lampe-biopsy-key.csv")

#args = c("lists/lampe-biopsy-ercc38","keys/lampe-biopsy-key.csv","location,treatment")
#if (length(args) != 3) {
  #stop("Need three arguments: <list file> <key file> <comparison headers in keyfile>")
if (length(args) != 2) {
  stop("Need three arguments: <list file> <key file>")
} else if (!file.exists(args[1])) {
  stop("Need valid experiment list file") 
} else if (!file.exists(args[2])) {
  stop("Need valid key file as second argument")
}

# Get counts file from analysis/fname/fname.T.csv
bname = basename(args[1]) 
fname = paste(bname,"-count.T.csv",sep='')
dat = read.csv(file.path("analysis",bname,fname), header = TRUE, row.names=1)

# Filter low count reads
keep = rowSums(cpm(dat) > 3) >= 3
counts = dat[keep,]

## Read in key file
key = read.csv(args[2], header=TRUE, row.names=1)

## Create model comparison matrix with sample key
#############################################
#factors = key[unlist(strsplit(args[3],","))]
#############################################

#############################################
#factors = key[c("tissue","location","treatment")]
#factors$treatment = relevel(factors$treatment, "placebo")
#design = model.matrix(~0+treatment+tissue+location, data=factors)
#############################################
# IDEAS:
# Filter out MT and ERCC reads (throwing off normalization? or no?)

#############################################
#factors = key[key$kit == "RNALater",]
factors = key[order(rownames(key)), c("idnum","tissue","location","treatment")]
factors$idnum = factor(factors$idnum)
factors$treatment = relevel(factors$treatment, "placebo")
design = model.matrix(~idnum+treatment+tissue+location, data=factors)
#############################################

#############################################
#groups = factor(paste(key$tissue,key$location,key$treatment,sep='.'))
#design = model.matrix(~0+groups)
#colnames(design) = levels(groups)
#############################################
counts = counts[,order(names(counts))]
# Read into DGEList for edgeR
y = DGEList(counts=counts)

## run analysis
y = estimateGLMCommonDisp(y, design)
y = estimateGLMTrendedDisp(y, design)
y = estimateGLMTagwiseDisp(y, design)
fit = glmFit(y, design)

## get counts for each group
#dfs = split.data.frame(t(counts), group)
#dfss = sapply(dfs, colMeans)

#group_names =c("DMSO1","Indo3", "TInd1", "TCDD1")
#group_names_means = sapply(group_names, function(x) paste("mean_",x,sep=""), USE.NAMES=FALSE)
#colnames(dfss) = group_names_means

#### Write results
run_analysis = function(outfile, contrast=NULL, coef=NULL) {
  lrt = glmLRT(fit, contrast=contrast, coef=coef) 
  ot1 = topTags(lrt,n=nrow(counts),sort.by="PValue")$table
  #sel = which(as.logical(contrast))
  #ot1 = merge(ot1, dfss[,sel], by=0)
  write.csv(ot1,outfile)
  #file.path(basename(outfile),"meta.txt")
  #detags = rownames(topTags(lrt,n=20))
  print(outfile)
  #print(cpm(y)[detags,])
  print(summary(decideTestsDGE(lrt, p=0.05, adjust="BH")))
  print(summary(decideTestsDGE(lrt, p=0.05, adjust="none")))
}
## output P-value csvs
#"treatmentplacebo:locationRectum"  "treatmentLignans:locationRectum" "treatmentplacebo:locationSigmoid" "treatmentLignans:locationSigmoid
#run_analysis(file.path("analysis",bname,"edger-treatment-rectum.csv"), contrast=c(-1,1,0,0))
#run_analysis(file.path("analysis",bname,"edger-treatment-sigmoid.csv"), contrast=c(0,0,-1,1))
#run_analysis(file.path("analysis",bname,"edger-location-placebo.csv"), contrast=c(-1,0,1,0))
#run_analysis(file.path("analysis",bname,"edger-location-lignan.csv"), contrast=c(0,-1,0,1))

#mycons = makeContrasts(
                #xRE=Epithelial.Rectum.Lignans-Epithelial.Rectum.placebo, 
                #xSE=Epithelial.Sigmoid.Lignans-Epithelial.Sigmoid.placebo, 
                #xRS=Stromal.Rectum.Lignans-Stromal.Rectum.placebo, 
                #xSS=Stromal.Sigmoid.Lignans-Stromal.Sigmoid.placebo, 
                #levels=design)
##[1] "Epithelial.Rectum.Lignans"  "Epithelial.Rectum.placebo" 
##[3] "Epithelial.Sigmoid.Lignans" "Epithelial.Sigmoid.placebo"
##[5] "Stromal.Rectum.Lignans"     "Stromal.Rectum.placebo"    
##[7] "Stromal.Sigmoid.Lignans"    "Stromal.Sigmoid.placebo"  
#run_analysis(file.path("analysis",bname,"edger-treatment-rectum.csv"), 


system(paste("mkdir -p ",file.path("analysis",bname,"edger")))

run_analysis(file.path("analysis",bname,"edger","edger2-Lignans.csv"),coef=11) 
run_analysis(file.path("analysis",bname,"edger","edger2-Stromal.csv"),coef=12)
run_analysis(file.path("analysis",bname,"edger","edger2-Sigmoid.csv"),coef=13)

## output MA, MDS, etc.., plots
png(file.path("analysis",bname,"edger","edger-mds.png"))
p = plotMDS(y)
dev.off()

png(file.path("analysis",bname,"edger","edger-bcv.png"))
p = plotBCV(y)
dev.off()
