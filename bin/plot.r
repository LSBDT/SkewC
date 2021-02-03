library(reshape2)
library(ggplot2)
library(Rmisc)
library(knitr)
library(tclust)
#library(dplyr)

### SkewC_Create_Coverage_Matrixes.Rmd ###

args=commandArgs(trailingOnly=TRUE)
if(length(args)==0){stop("Rscript --vanilla SkewC.r COVERAGE PLOT NAME",call.=FALSE)}
coverageFile<-args[1]
plotDir<-args[2]
dataName<-args[3]
basename<-basename(coverageFile)
source(coverageFile)
vars<-ls(pattern=dataName)
nvars<-length(vars)
CoverageValues<-list()
j<-1
for (i in 1:nvars){
  if (class(get(vars[i]))=="numeric"){
    CoverageValues[[j]]<-get(vars[i])
    names(CoverageValues)[j]<-vars[i]
    j<-j+1
  }
}
Coverage_DF<-as.data.frame(t(as.data.frame(CoverageValues)))
Coverage_DF$Annotation<-rownames(Coverage_DF)
rownames(Coverage_DF)<-NULL
dfv<-as.character(dataName)
Coverage_DF$Annotation<-gsub(dfv,"",Coverage_DF$Annotation)
Coverage_means_DF<-Coverage_DF
p10<-c(names(Coverage_means_DF)[1:10])
p20<-c(names(Coverage_means_DF)[11:20])
p30<-c(names(Coverage_means_DF)[21:30])
p40<-c(names(Coverage_means_DF)[31:40])
p50<-c(names(Coverage_means_DF)[41:50])
p60<-c(names(Coverage_means_DF)[51:60])
p70<-c(names(Coverage_means_DF)[61:70])
p80<-c(names(Coverage_means_DF)[71:80])
p90<-c(names(Coverage_means_DF)[81:90])
p100<-c(names(Coverage_means_DF)[91:100])
Coverage_means_DF$pmeanAve10<-rowMeans(Coverage_means_DF[c(p10)],na.rm=TRUE)
Coverage_means_DF$pmeanAve20<-rowMeans(Coverage_means_DF[c(p20)],na.rm=TRUE)
Coverage_means_DF$pmeanAve30<-rowMeans(Coverage_means_DF[c(p30)],na.rm=TRUE)
Coverage_means_DF$pmeanAve40<-rowMeans(Coverage_means_DF[c(p40)],na.rm=TRUE)
Coverage_means_DF$pmeanAve50<-rowMeans(Coverage_means_DF[c(p50)],na.rm=TRUE)
Coverage_means_DF$pmeanAve60<-rowMeans(Coverage_means_DF[c(p60)],na.rm=TRUE)
Coverage_means_DF$pmeanAve70<-rowMeans(Coverage_means_DF[c(p70)],na.rm=TRUE)
Coverage_means_DF$pmeanAve80<-rowMeans(Coverage_means_DF[c(p80)],na.rm=TRUE)
Coverage_means_DF$pmeanAve90<-rowMeans(Coverage_means_DF[c(p90)],na.rm=TRUE)
Coverage_means_DF$pmeanAve100<-rowMeans(Coverage_means_DF[c(p100)],na.rm=TRUE)
Coverage_means_DF<-Coverage_means_DF[,-c(1:100)]
Coverage_means_DF_Clust<-Coverage_means_DF

### plot ###

knitr::opts_knit$set(verbose=TRUE)
options(width=100)
Coverage_means_DF_Clust_Annotation<-Coverage_means_DF_Clust
Coverage_means_DF_Clust$Annotation<-NULL
alphavalue<-seq(0,0.3,by=0.005)
data<-ctlcurves(Coverage_means_DF_Clust,k=1,alpha=alphavalue)
pdf(paste(plotDir,paste(basename,".pdf"),sep="/"))
plot(data)
dev.off()
table<-data$obj
size<-length(alphavalue)
highestAlpha=0;
highestTable=0
for(i in 1:size){
  if(table[i]>highestTable){
    highestAlpha=alphavalue[i]
    highestTable=table[i]
  }
}