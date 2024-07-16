## ---query the API------------------------------------------------------------------------------------

# Load the necessary libraries
library(httr)
library(jsonlite)

# Source configini file to get NEON token

source("/Users/kelsey/Github/neon-biorepo-tools/configini.R")

## ---Functions to find sampleClasses for a given sampleID------------------------------------------------------------------------------------

find.sampleClass <- function(sampleID){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/classes?sampleTag=",sampleID,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}


## ---Sample Views Functions------------------------------------------------------------------------------------

# Functions to request data using the GET function & the API call & Make the data readable by jsonlite & flatten into list

view.sampID <- function(sampleID,sampleClass){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/view?sampleTag=",sampleID,
              "&sampleClass=",sampleClass,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

view.uuid <- function(sampleUuid){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/view?sampleUuid=",sampleUuid,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

view.barcode <- function(sampleCode){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/view?barcode=",sampleCode,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

view.IGSN <- function(IGSN){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/view?archiveGuid=",IGSN,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}



## ---Sample Downloads Functions------------------------------------------------------------------------------------

download.sampID <- function(sampleID,sampleClass){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/download?sampleTag=",sampleID,
                 "&sampleClass=",sampleClass,"&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

download.uuid <- function(sampleUuid){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/download?sampleUuid=",sampleUuid,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

download.barcode <- function(sampleCode){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/download?barcode=",sampleCode,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}

download.IGSN <- function(IGSN){
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/download?archiveGuid=",IGSN,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  return(avail)
}