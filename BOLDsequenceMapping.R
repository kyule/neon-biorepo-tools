library(dplyr)
library(stringr)

# Read in the sequence data already available in the biorepo portal
seqs<-restringrseqs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/sequencesInDatabase.csv")

# Load all NEON BOLD fish, mosquito, and beetle data
bold<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/BOLD_toDate_mos_fsh_bet.csv")

# Read in all of the biorepo occurrences from potentially associated collections
occs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/occurrencesFromCollectionsWithGeneticSequences.csv")

# assign sampleIDs to the occurrences
occs$sampleID<-sapply(str_split(occs$otherCatalogNumbers,"NEON sampleID: "),"[",2)
occs$sampleID<-sapply(str_split(occs$sampleID,";"),"[",1)

# BOLD identifiers are not standardized over the life of the NEON project, so we need to concatenate all possible identifiers to find the matches
boldIdentifiers<-c(bold$sampleid,bold$catalognum,bold$fieldnum)
boldIdentifiers<-boldIdentifiers[which(boldIdentifiers!="")]
boldIdentifiers<-boldIdentifers

# Find matches between occurrence records and BOLD records
occsIndices<-c(which(occs$sampleID %in% boldIdentifiers),
               which(occs$catalogNumber %in% boldIdentifiers))
occsMatches<-occs[!duplicated(occsIndices),]
boldIndices<-c(which(bold$sampleid %in% occs$sampleID),
               which(bold$catalognum %in% occs$catalogNumber),
               which(bold$fieldnum %in% occs$sampleID))
boldMatches<-bold[!duplicated(boldIndices),]

