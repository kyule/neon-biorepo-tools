library(dplyr)
library(stringr)

# Define the path
path<-"/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/"

# Read in the sequence data already available in the biorepo portal
seqs<-read.csv(paste0(path,"sequencesInDatabase.csv"))

# Load all NEON BOLD fish, mosquito, and beetle data
bold<-read.csv(paste0(path,"BOLD_toDate_mos_fsh_bet.csv"))

# Read in all of the biorepo occurrences from potentially associated collections
occs<-read.csv(paste0(path,"occurrencesFromCollectionsWithGeneticSequences.csv"))

# assign sampleIDs to the occurrences
occs$sampleID<-sapply(str_split(occs$otherCatalogNumbers,"NEON sampleID: "),"[",2)
occs$sampleID<-sapply(str_split(occs$sampleID,";"),"[",1)

# BOLD identifiers are not standardized over the life of the NEON project, so we need to concatenate all possible identifiers to find the matches
boldIdentifiers<-c(bold$sampleid,bold$catalognum,bold$fieldnum)
boldIdentifiers<-boldIdentifiers[which(boldIdentifiers!="")]
boldIdentifiers<-unique(boldIdentifiers)

# Find matches between occurrence records and BOLD records
occsIndices<-c(which(occs$sampleID %in% boldIdentifiers),
               which(occs$catalogNumber %in% boldIdentifiers))
occsMatches<-occs[unique(occsIndices),]
boldIndices<-c(which(bold$sampleid %in% occs$sampleID),
               which(bold$catalognum %in% occs$catalogNumber),
               which(bold$fieldnum %in% occs$sampleID))
boldMatches<-bold[unique(boldIndices),]

# Join the matches and existing sequence data

matches <- occsMatches %>%
              left_join(boldMatches,join_by("sampleID"=="sampleid"))
              left_join(seqs, join_by("id"=="occid"))

# Pull out ones with existing sequence data and make updated data frame

occSeq <- matches %>% filter(idoccurgenetic>0)
seqUpdate <- data.frame(idoccurgenetic=occSeq$idoccurgenetic,
                        occid=occSeq$id,
                        identifier=occSeq$processid,
                        resourcename="Barcode of Life (BOLD)",
                        locus="Cytochrome Oxidase Subunit 1 5' Region",
                        resourceurl=paste0("https://boldsystems.org/index.php/Public_RecordView?processid=",occSeq$processid),
                        notes=paste0("NEON sampleID: ",occSeq$sampleID))
write.csv(seqUpdate,paste0(path,"updateExistingOmoccurgenetic.csv"),row.names=FALSE)

# Load the above into a temporary table in the database and update via sql 


# Get new records to load in

matches <- matches[-which(matches$id %in% occSeq$id),]
newSeqs <- data.frame(occid=matches$id,
                        identifier=matches$processid,
                        resourcename="Barcode of Life (BOLD)",
                        locus="Cytochrome Oxidase Subunit 1 5' Region",
                        resourceurl=paste0("https://boldsystems.org/index.php/Public_RecordView?processid=",matches$processid),
                        notes=paste0("NEON sampleID: ",matches$sampleID))
