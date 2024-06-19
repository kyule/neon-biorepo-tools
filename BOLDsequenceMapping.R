library(dplyr)

seqs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/sequencesInDatabase.csv")
bold<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/BOLD_toDate_mos_fsh_bet.csv")
occs<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/BOLD_20240618/occurrencesFromCollectionsWithGeneticSequences.csv")