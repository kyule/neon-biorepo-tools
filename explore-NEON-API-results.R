#### Explore results of NEON sample endpoint API results

# Call file with functions
source("/Users/kelsey/Github/neon-biorepo-tools/NEON-API-calls.R")

# Get data for a sample via different methods

NEON.BET.D01.000444.Class<-find.sampleClass("NEON.BET.D01.000444")
NEON000A1<-view.IGSN("NEON000A1")
NEON000A1.tree<-download.IGSN("NEON000A1",100)


library(httr)
library(tidyr)
library(stringr)

samps<-read.csv('~/Downloads/samps.csv')

samps$sampleID<-str_replace(samps$sampleID," ","")

a<-view.sampID(samps$sampleID[1],samps$sampleClass[1])
b<-a %>% unnest(col=sampleEvents)
c<-b %>% unnest(col=smsFieldEntries)
fullData<-c %>% group_by(sampleTag,ingestTableName, smsKey) %>%
  mutate(row_id = row_number()) %>%
  ungroup()

for (i in 1:nrow(samps)){
  a<-view.sampID(samps$sampleID[i],samps$sampleClass[i])
  b<-a %>% unnest(col=sampleEvents)
  c<-b %>% unnest(col=smsFieldEntries)
  d<-c %>% group_by(sampleTag,ingestTableName, smsKey) %>%
    mutate(row_id = row_number()) %>%
    ungroup()
  fullData<-rbind(fullData,d)
}



view.locations <- function(namedLocation){
  reqURL<-paste0("https://data.neonscience.org/api/v0/locations/",namedLocation,"?history=true&apiToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJuZW9uLWJpb3JlcG8tc2VydmljZSIsInNjb3BlIjoibmVvbjpzZXJ2aWNlIHJlYWQ6c2FtcGxlcyByZWFkOnNhbXBsZXMtdGF4YSByb2xlOmJpb3JlcG8iLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImlhdCI6MTYyMDEzOTc3Nn0.84h3ungTPAQnak_GGiZuerlP_tseJTapJ7M0q3Losk98fVg4EDzFnkKFFhWNlPiRthBbjLx7r2gdbZEQYhDkfA")
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$locationHistory
  return(avail.data)
}

locations<-read.csv("~/Downloads/namedLocations.csv")

e<-view.locations(locations$locationID[2])
fullData<-data.frame(locationID=locations$locationID[2],e)

for (i in 3:nrow(locations)){
  e<-view.locations(locations$locationID[i])
  if (!is.null(e)){
    f<-data.frame(locationID=rep(locations$locationID[i],nrow(e)),e)
    fullData<-bind_rows(fullData,f)}
}
\
