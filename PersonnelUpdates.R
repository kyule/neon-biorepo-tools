# Update the NEON Personnel List for harvesting

pers<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list.csv")
old<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/old NEON personnel list.csv")

old[old=="NULL"]<-""
old.noid<-old[,2:7]
old.noid$dataset<-"old"

pers<-pers[,2:5]
pers<-pers[!duplicated(pers),]

new<-data.frame(neon_email=pers$neon_email_address,orcid=pers$orcid,last_name=pers$last_name,first_name=pers$first_name,full_name=paste(pers$first_name,pers$last_name,sep=" "))
new$full_info<-paste0(new$full_name," (ORCID ",new$orcid,")")
new$full_info<-str_replace(new$full_info," (ORCID )","")
new$dataset<-"new"


full<-rbind(old.noid,new)
full<-full[!duplicated(full[,1:6]),]

dupe.orcid<-full[duplicated(full$orcid),]
#dupe.orcid<-
