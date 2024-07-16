library(dplyr)

seqs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/sequencesInDatabase.csv")
bold<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/BOLD_toDate_mos_fsh_bet.csv")
occs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/occurrencesFromCollectionsWithGeneticSequences.csv")

occs$sampleID<-sapply(str_split(occs$otherCatalogNumbers,"NEON sampleID: "),"[",2)
occs$sampleID<-sapply(str_split(occs$sampleID,";"),"[",1)

boldIdentifiers<-c(bold$sampleid,bold$catalognum,bold$fieldnum)
boldIdentifiers<-boldIdentifiers[which(boldIdentifiers!="")]

field<-NeonData$alg_fieldData

left_join(phor,field,join_by(sampleID==parentSampleID))-> genusPhormidiumJoinFieldData
write.csv(genusPhormidiumJoinFieldData,"~/Desktop/genusPhormidiumJoinFieldData.csv",row.names=TRUE)

