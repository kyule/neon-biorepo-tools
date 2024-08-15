library(tidyverse)

assoc<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/MAM/associations/AllAssociations.csv")
dets<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/MAM/associations/AllDeterminations_20240807.csv")

assoc[assoc=="NULL"]<-""
dets[dets=="NULL"]<-""


assoc$occidAssociate<-as.numeric(assoc$occidAssociate)

assoc.a<-assoc %>%
  filter(occid %in% dets$occid) %>%
  left_join(dets,by="occid")

assoc.b<-assoc %>%
  filter(occidAssociate %in% dets$occid) %>%
  left_join(dets,join_by("occidAssociate"=="occid"))

assoc.ids<-rbind(assoc.a,assoc.b)

assoc.ids$occid[which(assoc.ids$occid %in% dets$occid)]<-""
assoc.ids$occidAssociate[which(assoc.ids$occidAssociate %in% dets$occid)]<-""

assoc.ids<-assoc.ids[-which(assoc.ids$occid=="" & assoc.ids$occidAssociate==""),]
#assoc.ids<-assoc.ids[-which(assoc.ids$occid!="" & assoc.ids$occidAssociate!=""),]

assoc.ids$occid.NewDet<-as.numeric(paste0(assoc.ids$occid,assoc.ids$occidAssociate))
assoc.ids<-assoc.ids[!duplicated(assoc.ids$occid.NewDet),]


# Make sure to check which columns are relevant
newDets<-assoc.ids %>%
  select(occid.NewDet,identifiedBy,dateIdentified,
         family,sciname,scientificNameAuthorship,
         tidInterpreted,genus,specificEpithet,
         isCurrent,printQueue,appliedStatus,
         securityStatus,identificationReferences,
         identificationRemarks,taxonRemarks,
         sortSequence,enteredByUid)

# make past IDs for these individuals NOT CURRENT
# update the omoccurrences table as well!

write.csv(newDets,
          "/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/MAM/associations/newDeterminationsToLoad.csv",
          row.names=FALSE)

