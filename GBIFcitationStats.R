library(rgbif)
library(jsonlite)

date<-"20241010"
path<-paste0("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/GBIF statistics/",date)

litFunction<-function(Key){
  lit_count(datasetKey=Key)
}

downloadsFunction<-function(Key){
  fromJSON(paste0("https://api.gbif.org/v1/occurrence/download/statistics?datasetKey=",Key,"&limit=1000"))$results
}

allNEON<-datasets(query='NEON')
allNEON<-allNEON$data
allNEON<-data.frame(allNEON)
NEONdatasets<-allNEON[grepl("NEON",allNEON$title),]
litCounts<-sapply(NEONdatasets$key,litFunction)
litCounts<-as.numeric(unname(litCounts))
NEONdatasets$LitCitations<-litCounts
NEONdatasets<-data.frame(collection=NEONdatasets$title,key=NEONdatasets$key,citations=NEONdatasets$LitCitations)



allDownloads<-data.frame()
for (i in 1:nrow(NEONdatasets)){
  key<-NEONdatasets$key[i]
  downloadsDataset<-downloadsFunction(key)
  downloadsDataset<-cbind(rep(NEONdatasets$collection[i],nrow(downloadsDataset)),downloadsDataset)
  allDownloads<-rbind(allDownloads,downloadsDataset)
}

write.csv(NEONdatasets,paste0(path,"_datasetCitations.csv"),row.names=FALSE)
write.csv(allDownloads,paste0(path,"_datasetDownloads.csv"),row.names=FALSE)
