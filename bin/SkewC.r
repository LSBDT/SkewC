library(magicfor)
library(reshape2)
library(ggplot2)
library(Rmisc)
library(knitr)
library(tclust)

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
for(i in 1:nvars){
  if(class(get(vars[i]))=="numeric"){
    CoverageValues[[j]]<-get(vars[i])
    names(CoverageValues)[j]<-vars[i]
    j<-j+1
  }
}
magic_for(silent=TRUE)
for(h in vars){
  for(z in 1:100){
    nam<-paste("pmean",z,sep="")
    assign(nam,CoverageValues[[h]][z])
  }
  put(pmean1,pmean2,pmean3,pmean4,pmean5,pmean6,pmean7,pmean8,pmean9,pmean10,pmean11,pmean12,pmean13,pmean14,pmean15,pmean16,pmean17,pmean18,pmean19,pmean20,pmean21,pmean22,pmean23,pmean24,pmean25,pmean26,pmean27,pmean28,pmean29,pmean30,pmean31,pmean32,pmean33,pmean34,pmean35,pmean36,pmean37,pmean38,pmean39,pmean40,pmean41,pmean42,pmean43,pmean44,pmean45,pmean46,pmean47,pmean48,pmean49,pmean50,pmean51,pmean52,pmean53,pmean54,pmean55,pmean56,pmean57,pmean58,pmean59,pmean60,pmean61,pmean62,pmean63,pmean64,pmean65,pmean66,pmean67,pmean68,pmean69,pmean70,pmean71,pmean72,pmean73,pmean74,pmean75,pmean76,pmean77,pmean78,pmean79,pmean80,pmean81,pmean82,pmean83,pmean84,pmean85,pmean86,pmean87,pmean88,pmean89,pmean90,pmean91,pmean92,pmean93,pmean94,pmean95,pmean96,pmean97,pmean98,pmean99,pmean100)
}
Coverage_DF<-magic_result_as_dataframe()
names(Coverage_DF)[1]<-"Annotation"
dfv<-as.character(dataName)
Coverage_DF$Annotation<-gsub(dfv,"",Coverage_DF$Annotation)
Coverage_means_DF<-Coverage_DF
p10<-c(names(Coverage_means_DF)[2:11])
p20<-c(names(Coverage_means_DF)[12:21])
p30<-c(names(Coverage_means_DF)[22:31])
p40<-c(names(Coverage_means_DF)[32:41])
p50<-c(names(Coverage_means_DF)[42:51])
p60<-c(names(Coverage_means_DF)[52:61])
p70<-c(names(Coverage_means_DF)[62:71])
p80<-c(names(Coverage_means_DF)[72:81])
p90<-c(names(Coverage_means_DF)[82:91])
p100<-c(names(Coverage_means_DF)[92:101])
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
Coverage_means_DF<-Coverage_means_DF[,-c(2:101)]
Coverage_means_DF_Clust<-Coverage_means_DF

### SkewC_Plot_Gene_Body_Coverage.Rmd ###

knitr::opts_chunk$set(echo=TRUE)
if(!file.exists(plotDir)){dir.create(plotDir)}
plotDir<-paste(plotDir,dataName,sep="/")
if(!file.exists(plotDir)){dir.create(plotDir)}
plotDir<-paste(plotDir,alphaValue,sep="/")
if(!file.exists(plotDir)){dir.create(plotDir)}
Coverage_DF_melted<-melt(Coverage_DF)
pdf(paste(plotDir,"FullCoverage.pdf",sep="/"))
color=rgb(0,0,0,alpha=0.25)
par(mai=c(0.82,0.82,0.41,0.12))
fullPlot<-ggplot(data=Coverage_DF_melted,aes(x=variable,y=value,group=Annotation))
fullPlot<-fullPlot+geom_line(aes(group=Annotation),size=0.25,col=color)
fullPlot<-fullPlot+scale_x_discrete(breaks=c("pmean1","pmean20","pmean40","pmean60","pmean80","pmean100"),labels=c("1","20","40","60","80","100"))
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
Coverage_means_DF_Clust_Annotation<-Coverage_means_DF_Clust
Coverage_means_DF_Clust$Annotation<-NULL
trimClust<-function(x) {
  clus<-tclust (
    Coverage_means_DF_Clust,
    k=1,
    alpha=as.numeric(alphaValue),
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
main=list(paste(dataName,"(n=",NROW(Coverage_DF),")","\n","cells clustering by gene body coverage")),
cex=1.5,
#col="black",
font=2
)
box(lty="solid",col='black',lwd=3)
axis(
side=1,
lwd=2,
lwd.ticks=4,
col.ticks="black"
)
axis(
side=2,
lwd=3,
lwd.ticks=4,
col.ticks="black"
)
dev.off()

clusoutdf<-as.data.frame(trimClustResult$cluster)
Coverage_means_DF_Clust_AnnotationBINF <-
cbind(Coverage_means_DF_Clust_Annotation,trimClustResult$cluster)
TypicalCells_cellID<-subset(
Coverage_means_DF_Clust_AnnotationBINF,
Coverage_means_DF_Clust_AnnotationBINF$`trimClustResult$cluster`== 1
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
      Coverage_means_DF_Clust_AnnotationBINF$`trimClustResult$cluster`== 0
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
    fullPlotTypical + geom_line(aes(group=Annotation),size=0.25,col=
    color)
    fullPlotTypical <-
    fullPlotTypical + scale_x_discrete(
    breaks=c("pmean1","pmean20","pmean40","pmean60","pmean80","pmean100"),
    labels=c("1","20","40","60","80","100")
    )
    fullPlotTypical <-
      fullPlotTypical + coord_cartesian(xlim=c(-3,103))
      fullPlotTypical <-
      fullPlotTypical + labs(x="Mean of the gene body percentile       (5'-> 3')") +
      labs(y="Gene coverage") +
      labs(title=paste(dataName,":Typical cells","\n","(n=",
      NROW(Coverage_DF_meltedTypicalCells)/100,
      ":",
      NROW(Coverage_DF_melted)/100,
      ")"
      ))
fullPlotTypical=fullPlotTypical+ theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
fullPlotTypical=fullPlotTypical+ theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
fullPlotTypical=fullPlotTypical+ theme(axis.ticks.length=unit(.2,"cm"))
fullPlotTypical=fullPlotTypical+ theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotTypical=fullPlotTypical+ theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotTypical=fullPlotTypical+ theme(legend.position="none")
fullPlotTypical=fullPlotTypical+ theme(axis.text=element_text(face="bold",colour="black",size=18))
fullPlotTypical=fullPlotTypical+ theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
fullPlotTypical=fullPlotTypical+ theme(plot.title=element_text(hjust=0.5))
fullPlotTypical
dev.off()

Coverage_DF_meltedSkewedCells <-
  subset(Coverage_DF_melted,Annotation %in% Skewed_coverage_cellIDDF$V1)
pdf(paste(plotDir,"SkewedcellFullCoverage.pdf",sep="/"))
color=rgb(0,0,0,alpha=0.25)
par(mai=c(0.82,0.82,0.41,0.12))

fullPlotSkewed<-ggplot(data=Coverage_DF_meltedSkewedCells,aes(x=variable,y=value,group=Annotation))
fullPlotSkewed<-fullPlotSkewed + geom_line(aes(group=Annotation),size=0.25,col=color)
fullPlotSkewed<-fullPlotSkewed + scale_x_discrete(breaks=c("pmean1","pmean20","pmean40","pmean60","pmean80","pmean100"),labels= c("1","20","40","60","80","100"))
fullPlotSkewed<-fullPlotSkewed + coord_cartesian(xlim=c(-3,103))
fullPlotSkewed<-fullPlotSkewed+ labs(x= "Mean of the gene body percentile (5'-> 3')") +
  labs(y="Gene coverage") + labs(title=paste(
    dataName,
    ":Skewed cells","\n","(n=",
    NROW(Coverage_DF_meltedSkewedCells)/100,
    ":",
    NROW(Coverage_DF_melted)/100,
    ")"
  ))
fullPlotSkewed=fullPlotSkewed+ theme(plot.title=element_text(face="bold",colour="black",size=20,margin=margin(0,0,3,0)))
fullPlotSkewed=fullPlotSkewed+ theme(axis.ticks=element_line(colour='black',size=1.2,linetype='dashed'))
fullPlotSkewed=fullPlotSkewed+ theme(axis.ticks.length=unit(.2,"cm"))
fullPlotSkewed=fullPlotSkewed+ theme(axis.title.x=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotSkewed=fullPlotSkewed+ theme(axis.title.y=element_text(face="bold",colour="black",size=18,family="Times"))
fullPlotSkewed=fullPlotSkewed+ theme(legend.position="none")
fullPlotSkewed=fullPlotSkewed+ theme(axis.text=element_text(face="bold",colour="black",size=18))
fullPlotSkewed=fullPlotSkewed+ theme(panel.border=element_rect(colour="black",fill=NA,size=2.2),panel.background=element_rect(fill=NA))
fullPlotSkewed=fullPlotSkewed+ theme(plot.title=element_text(hjust=0.5))
fullPlotSkewed
dev.off()
