#### split manifests with pipes into multiple rows
library(plyr)

datapath<-"/Users/kelsey/Downloads/Manifest_ KBS_006_20240409_ pre-receipt_2022.csv"

data<-read.csv(datapath)


rep.row <- function(r, n){
  colwise(function(x) rep(x, n))(r)
}

fixed<-data.frame()

for (i in 1:nrow(data)){
  a<-strsplit(data$sampleID[i],"[|]")[[1]]
  reps<-rep.row(data[i,],length(a))
  reps$sampleID<-a
  fixed<-rbind(fixed,reps)
}

if(length(unlist(strsplit(data$sampleID,"[|]")))==nrow(fixed))
   {write.csv(fixed,datapath,row.names=FALSE)} else {print("ERROR Wrong sampleID number")}



