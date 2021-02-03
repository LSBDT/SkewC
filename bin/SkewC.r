library(reshape2)
library(ggplot2)
library(Rmisc)
library(knitr)
library(tclust)
#library(dplyr)

### SkewC_Create_Coverage_Matrixes.Rmd ###

args=commandArgs(trailingOnly=TRUE)
if(length(args)==0){stop("Rscript --vanilla SkewC.r COVERAGE PLOT NAME ALPHA",call.=FALSE)}
coverageFile<-args[1]
plotDir<-args[2]
dataName<-args[3]
alphaValue<-args[4]
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
Coverage_means_DF_Clust_Annotation<-Coverage_means_DF_Clust
Coverage_means_DF_Clust$Annotation<-NULL
### alphaValue ###
knitr::opts_chunk$set(echo=TRUE)
if(!file.exists(plotDir)){dir.create(plotDir)}
plotDir<-paste(plotDir,dataName,sep="/")
if(!file.exists(plotDir)){dir.create(plotDir)}
if(is.na(alphaValue)){
  alphaRange<-seq(0,0.3,by=0.005)
  data<-ctlcurves(Coverage_means_DF_Clust,k=1,alpha=alphaRange)
  table<-data$obj
  size<-length(alphaRange)
  highestTable=0
  for(i in 1:size){
    if(is.infinite(table[i])){data$obj[i]=0}
    if(table[i]>highestTable){
      alphaValue<-alphaRange[i]
      highestTable<-table[i]
    }
  }
  plotDir<-paste(plotDir,alphaValue,sep="/")
  if(!file.exists(plotDir)){dir.create(plotDir)}
  pdf(paste(plotDir,paste("ctlcurves.pdf"),sep="/"))
  plot(data)
  dev.off()
}else{
  alphaValue<-as.numeric(alphaValue)
  plotDir<-paste(plotDir,alphaValue,sep="/")
  if(!file.exists(plotDir)){dir.create(plotDir)}
}
### SkewC_Plot_Gene_Body_Coverage.Rmd ###
knitr::opts_knit$set(verbose=TRUE)
Coverage_DF_melted<-melt(Coverage_DF)
pdf(paste(plotDir,"FullCoverage.pdf",sep="/"))
color=rgb(0,0,0,alpha=0.25)
par(mai=c(0.82,0.82,0.41,0.12))
fullPlot<-ggplot(data=Coverage_DF_melted,aes(x=variable,y=value,group=Annotation))
fullPlot<-fullPlot+geom_line(aes(group=Annotation),size=0.25,col=color)
fullPlot<-fullPlot+scale_x_discrete(breaks=c("V1","V20","V40","V60","V80","V100"),labels=c("1","20","40","60","80","100"))
fullPlot<-fullPlot+coord_cartesian(xlim=c(-3,103))
fullPlot<-fullPlot+labs(x="Gene body percentile(5'->3')")+labs(y="Gene coverage")+labs(title=paste(dataName,"(n=",NROW(Coverage_DF_melted)/100,")"))
fullPlot=fullPlot+theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
fullPlot=fullPlot+theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
fullPlot=fullPlot+theme(axis.ticks.length=unit(.2,"cm"))
fullPlot=fullPlot+theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlot=fullPlot+theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlot=fullPlot+theme(legend.position="none")
fullPlot=fullPlot+theme(axis.text=element_text(face="bold",colour="black",size=18))
fullPlot=fullPlot+theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
fullPlot=fullPlot+theme(plot.title=element_text(hjust=0.5))
fullPlot
dev.off()
Coverage_means_DF[1:NROW(Coverage_means_DF),1]<-dataName
Coverage_means_DF<-melt(Coverage_means_DF)
Coverage_means_DF_tgc<-summarySE(Coverage_means_DF,measurevar="value",groupvars=c("Annotation","variable"))
pdf(paste(plotDir,"MeanCoverage.pdf",sep="/"))
meanPlot<-ggplot(Coverage_means_DF_tgc,aes(x=variable,y=value))+geom_errorbar(aes(ymin=value-ci,ymax=value+ci))+geom_line(aes(group=Annotation))
meanPlot=meanPlot+geom_point(aes(group=1),size=2,shape=21,fill="white")+scale_x_discrete(labels=c(10,20,30,40,50,60,70,80,90,100))+labs(x="Mean of the gene body percentile(5'->3')")+labs(y="Gene coverage")+labs(title=paste(dataName,"(n=",NROW(Coverage_DF),")"))
meanPlot=meanPlot+theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
meanPlot=meanPlot+theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
meanPlot=meanPlot+theme(axis.ticks.length=unit(.2,"cm"))
meanPlot=meanPlot+theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
meanPlot=meanPlot+theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
meanPlot=meanPlot+theme(legend.position="none")
meanPlot=meanPlot+theme(axis.text=element_text(face="bold",colour="black",size=18))
meanPlot=meanPlot+theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
meanPlot=meanPlot+theme(plot.title=element_text(hjust=0.5))
meanPlot
dev.off()
### SkewC_TrimClustering.Rmd ###
knitr::opts_knit$set(verbose=TRUE)
options(width=100)
trimClust<-function(x) {
  clus<-tclust (
    Coverage_means_DF_Clust,
    k=1,
    alpha=alphaValue,
    restr.fact=1,
    restr="eigen",
    equal.weights=TRUE
  )
  result<-clus
  return(result)
}
trimClustResult<-trimClust(x)
pdf(paste(plotDir,"CLUSTResult.pdf",sep="/"))
plot(
trimClustResult,
main=list(paste(dataName,"(n=",NROW(Coverage_DF),") alpha=",
      alphaValue,"\n","cells clustering by gene body coverage")),
cex=1.5,
#col="black",
font=2
)
box(lty="solid",col='black',lwd=3)
axis(side=1,lwd=2,lwd.ticks=4,col.ticks="black")
axis(side=2,lwd=3,lwd.ticks=4,col.ticks="black")
dev.off()

clusoutdf<-as.data.frame(trimClustResult$cluster)
Coverage_means_DF_Clust_AnnotationBINF <-
cbind(Coverage_means_DF_Clust_Annotation,trimClustResult$cluster)
TypicalCells_cellID<-subset(
Coverage_means_DF_Clust_AnnotationBINF,
Coverage_means_DF_Clust_AnnotationBINF$`trimClustResult$cluster`==1
)
write.table(
  TypicalCells_cellID$Annotation,
  file=paste(plotDir,"TypicalCellsID.tsv",sep="/"),
  sep="\t",
  row.names=F,
  quote=F,
  col.names=F
  )
  TypicalCells_cellIDDF <-
  as.data.frame(TypicalCells_cellID$Annotation)
  names(TypicalCells_cellIDDF)[1]<-"V1"
  Skewed_coverage_cellID <-
    subset(
      Coverage_means_DF_Clust_AnnotationBINF,
      Coverage_means_DF_Clust_AnnotationBINF$`trimClustResult$cluster`==0
    )
  write.table(
    Skewed_coverage_cellID$Annotation,
    file=paste(plotDir,"SkewedCellsID.tsv",sep="/"),
    sep="\t",
    row.names=F,
    quote=F,
    col.names=F
  )
  Skewed_coverage_cellIDDF <-
    as.data.frame(Skewed_coverage_cellID$Annotation)
    names(Skewed_coverage_cellIDDF)[1]<-"V1"

### SkewC_Plot_Typical_Skewed_Coverage.Rmd ###

knitr::opts_chunk$set(echo=TRUE)

Coverage_DF_meltedTypicalCells <-
  subset(Coverage_DF_melted,Annotation %in% TypicalCells_cellIDDF$V1)
  pdf(paste(plotDir,"TypicalcellFullCoverage.pdf",sep="/"))
  color=rgb(0,0,0,alpha=0.25)
  par(mai=c(0.82,0.82,0.41,0.12))

  fullPlotTypical <-
    ggplot(data=Coverage_DF_meltedTypicalCells,aes(x=variable,y=value,group=
    Annotation))
    fullPlotTypical <-
    fullPlotTypical+geom_line(aes(group=Annotation),size=0.25,col=
    color)
    fullPlotTypical <-
    fullPlotTypical+scale_x_discrete(
    breaks=c("V1","V20","V40","V60","V80","V100"),
    labels=c("1","20","40","60","80","100")
    )
    fullPlotTypical <-
      fullPlotTypical+coord_cartesian(xlim=c(-3,103))
      fullPlotTypical <-
      fullPlotTypical+labs(x="Mean of the gene body percentile       (5'-> 3')")+
      labs(y="Gene coverage")+
      labs(title=paste(dataName,":Typical cells","\n","(n=",
      NROW(Coverage_DF_meltedTypicalCells)/100,
      ":",
      NROW(Coverage_DF_melted)/100,
      ") alpha=",
      alphaValue
      ))
fullPlotTypical=fullPlotTypical+theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
fullPlotTypical=fullPlotTypical+theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
fullPlotTypical=fullPlotTypical+theme(axis.ticks.length=unit(.2,"cm"))
fullPlotTypical=fullPlotTypical+theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotTypical=fullPlotTypical+theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotTypical=fullPlotTypical+theme(legend.position="none")
fullPlotTypical=fullPlotTypical+theme(axis.text=element_text(face="bold",colour="black",size=18))
fullPlotTypical=fullPlotTypical+theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
fullPlotTypical=fullPlotTypical+theme(plot.title=element_text(hjust=0.5))
fullPlotTypical
dev.off()

Coverage_DF_meltedSkewedCells <-
  subset(Coverage_DF_melted,Annotation %in% Skewed_coverage_cellIDDF$V1)
pdf(paste(plotDir,"SkewedcellFullCoverage.pdf",sep="/"))
color=rgb(0,0,0,alpha=0.25)
par(mai=c(0.82,0.82,0.41,0.12))

fullPlotSkewed<-ggplot(data=Coverage_DF_meltedSkewedCells,aes(x=variable,y=value,group=Annotation))
fullPlotSkewed<-fullPlotSkewed+geom_line(aes(group=Annotation),size=0.25,col=color)
fullPlotSkewed<-fullPlotSkewed+scale_x_discrete(breaks=c("V1","V20","V40","V60","V80","V100"),labels= c("1","20","40","60","80","100"))
fullPlotSkewed<-fullPlotSkewed+coord_cartesian(xlim=c(-3,103))
fullPlotSkewed<-fullPlotSkewed+labs(x= "Mean of the gene body percentile (5'-> 3')")+
  labs(y="Gene coverage")+labs(title=paste(
    dataName,
    ":Skewed cells","\n","(n=",
    NROW(Coverage_DF_meltedSkewedCells)/100,
    ":",
    NROW(Coverage_DF_melted)/100,
    ") alpha=",
      alphaValue
  ))
fullPlotSkewed=fullPlotSkewed+theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
fullPlotSkewed=fullPlotSkewed+theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
fullPlotSkewed=fullPlotSkewed+theme(axis.ticks.length=unit(.2,"cm"))
fullPlotSkewed=fullPlotSkewed+theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotSkewed=fullPlotSkewed+theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotSkewed=fullPlotSkewed+theme(legend.position="none")
fullPlotSkewed=fullPlotSkewed+theme(axis.text=element_text(face="bold",colour="black",size=18))
fullPlotSkewed=fullPlotSkewed+theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
fullPlotSkewed=fullPlotSkewed+theme(plot.title=element_text(hjust=0.5))
fullPlotSkewed
dev.off()
