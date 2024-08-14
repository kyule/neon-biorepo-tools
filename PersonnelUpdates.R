# Update the NEON Personnel List for harvesting

library(dplyr)
library(tools)


pers<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list.csv")
old<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/old NEON personnel list.csv")

old[old=="NULL"]<-""
old$neon_email[which(old$neon_email=="Unknown - added by hand")]<-""
old.noid<-old[,2:7]
old.noid$dataset<-"old"

pers<-pers[,2:5]
pers<-pers[!duplicated(pers),]
pers$orcid[which(pers$orcid=="0000-0000-0000-0000")]<-""
pers$neon_email_address[which(pers$neon_email_address=="Unknown - added by hand")]<-""


new<-data.frame(neon_email=pers$neon_email_address,
                orcid=pers$orcid,
                last_name=toTitleCase(pers$last_name),
                first_name=toTitleCase(pers$first_name))
new$full_name=paste(new$first_name,new$last_name,sep=" ")
new$full_info<-paste0(new$full_name," (ORCID ",new$orcid,")")
new$full_info<-str_replace(new$full_info," \\(ORCID \\)","")
new$full_info<-str_replace(new$full_info,"  "," ")
new$full_info<-str_replace(new$full_info,"\\n"," ")
new$dataset<-"new"


full<-rbind(old.noid,new)
nospaces<- full %>%
  mutate(across(where(is.character), ~ str_replace_all(., " ", "")))
full<-full[!duplicated(nospaces[,1:6]),]
full<-full[-which(full$orcid=='1234-1234-1234-1234'),]




dupe.orcid<-full$orcid[duplicated(full$orcid)]
dupe.orcid.df<-full[full$orcid %in% dupe.orcid,]
dupe.orcid.df<-dupe.orcid.df[dupe.orcid.df$orcid!="",]

unique.dupes<-unique(dupe.orcid)

select.dupes<-c()

for (i in 1:length(unique.dupes)){
  orcid<-unique.dupes[i]
  dupes<-dupe.orcid.df %>% filter(orcid %in% orcid)
  select.dupes<-c(select.dupes,selected)
}


no.dupe.orcid.df<-full[-which(full$orcid %in% dupe.orcid),]

write.csv(full, "~/Downloads/personnel.csv",row.names=FALSE)
