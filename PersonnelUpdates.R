# Update the NEON Personnel List for harvesting

library(dplyr)
library(tools)

# load new personnel file and old one in database
pers<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list.csv")
old<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/old NEON personnel list.csv")

# clean many of the fields in both databases
old[old=="NULL"]<-""
old$neon_email[which(old$neon_email=="Unknown - added by hand")]<-""
old$first_name<-trimws(toTitleCase(old$first_name))
old$last_name<-trimws(toTitleCase(old$last_name))
old$orcid<-trimws(old$orcid)
old$full_name<-paste(old$first_name,old$last_name,sep=" ")
old$full_info<-paste0(old$full_name," (ORCID ",old$orcid,")")
old$full_info<-str_replace(old$full_info," \\(ORCID \\)","")
old$full_info<-str_replace(old$full_info,"  "," ")
old$full_info<-str_replace(old$full_info,"\\n"," ")
old$neon_email<-trimws(tolower(old$neon_email))
old<-old[,2:7]
old$dataset<-"old"

pers<-pers[,2:5]
pers<-pers[!duplicated(pers),]
pers$orcid[which(pers$orcid=="0000-0000-0000-0000")]<-""
pers$neon_email_address[which(pers$neon_email_address=="Unknown - added by hand")]<-""

# create a new data frame from personnel list that is clean and has correct field names
new<-data.frame(neon_email=trimws(pers$neon_email_address),
                orcid=trimws(pers$orcid),
                last_name=trimws(toTitleCase(pers$last_name)),
                first_name=trimws(toTitleCase(pers$first_name)))
new$full_name=paste(new$first_name,new$last_name,sep=" ")
new$full_info<-paste0(new$full_name," (ORCID ",new$orcid,")")
new$full_info<-str_replace(new$full_info," \\(ORCID \\)","")
new$full_info<-str_replace(new$full_info,"  "," ")
new$full_info<-str_replace(new$full_info,"\\n"," ")
new$neon_email<-tolower(new$neon_email)
new$dataset<-"new"

# bind old and new databases
full<-rbind(old,new)
rm(new,pers)

# remove duplicates, the following considers differences in spaces as unimportant when determining duplicates
nospaces<- full %>%
  mutate(across(where(is.character), ~ str_replace_all(., " ", "")))

full<-full[!duplicated(nospaces[,1:6]),]

rm(nospaces)

# remove dummy record
full<-full[-which(full$orcid=='1234-1234-1234-1234'),]

# check for records with no email -- if they otherwise match existing records, do not keep them
no.emails<-full[which(full$neon_email==""),]
with.emails<-full[which(full$neon_email!=""),]

no.email.match <- anti_join(no.emails, 
                            with.emails,
                            by=c("orcid","last_name","first_name","full_name","full_info" ))

full<-rbind(no.email.match,with.emails)

rm(no.emails,no.email.match,with.emails)


# check for records with no orcid -- if they otherwise match existing records, do not keep them

no.orcid<-full[which(full$orcid==""),]
with.orcid<-full[which(full$orcid!=""),]

no.orcid.match <- anti_join(no.orcid, 
                            with.orcid,
                            by=c("neon_email","last_name","first_name","full_name"))

full<-rbind(no.orcid.match,with.orcid)

rm(no.orcid,no.orcid.match,with.orcid)

# check for duplicated full info, if those with no email are repeated just remove the ones without emails
dupe.full.info<-full[full$full_info %in% full$full_info[duplicated(full$full_info)],]
not.dupe.full.info<-full[-which(full$full_info %in% full$full_info[duplicated(full$full_info)]),]

dupe.full.info.check<-dupe.full.info[which(dupe.full.info$full_info %in% dupe.full.info$full_info[dupe.full.info$neon_email==""]),]
dupe.full.info.check.rem<-dupe.full.info[-which(dupe.full.info$full_info %in% dupe.full.info$full_info[dupe.full.info$neon_email==""]),]

full<-rbind(dupe.full.info.check.rem,not.dupe.full.info)

rm(dupe.full.info,dupe.full.info.check,not.dupe.full.info,dupe.full.info.check.rem)

# order the results and write to a file
full<-full[order(full$full_info),]

write.csv(full,"/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list Updated.csv",row.names=FALSE)
# Check file and remove issues, common is lack of last name

# Load hand cleaned file and check against old file
upload<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list Updated.csv")

new.recs.email<-anti_join(upload[upload$neon_email!="",],
                          old[old$neon_email!="",],
                          join_by("neon_email"=="neon_email"))
new.recs.orcid<-anti_join(upload[upload$orcid!="",],
                          old[old$orcid!="",],
                          join_by("orcid"=="orcid"))

old.recs.email<-anti_join(old[old$neon_email!="",],
                          upload[upload$neon_email!="",],
                          join_by("neon_email"=="neon_email"))
old.recs.orcid<-anti_join(old[old$orcid!="",],
                          upload[upload$orcid!="",],
                          join_by("orcid"=="orcid"))

# Load in full new file and check for "bad" records

newTotal<-read.csv("/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list Updated Database.csv")

newTotal[newTotal=="NULL"]<-""

badRecords<- anti_join(newTotal,
                       full,
                       by=c("neon_email","orcid","last_name","first_name","full_name","full_info" ))
# inspect by hand which ones should be deleted from the database
write.csv(badRecords,
          "/Users/kelsey/Library/CloudStorage/GoogleDrive-kmyule@asu.edu/My Drive/NEON Biorepository/Informatics/Collection Updates & Data QA:QC/Personnel/20240814/NEON personnel list Updated Database Bad Records.csv",
          row.names=FALSE)

