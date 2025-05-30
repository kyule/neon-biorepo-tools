## ---query the API------------------------------------------------------------------------------------

# Load the necessary libraries
library(httr)
library(jsonlite)

# Source configini file to get NEON token

source("/Users/kelsey/Github/neon-biorepo-tools/configini.R")

## ---Function to find sampleClasses for a given sampleID------------------------------------------------------------------------------------

find.sampleClass <- function(sampleID){
  encoded_sampleID <- URLencode(sampleID, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/classes?sampleTag=",encoded_sampleID,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleClasses
  return(avail.data)
}


## ---Sample Views Functions------------------------------------------------------------------------------------

# Functions to request data using the GET function & the API call & Make the data readable by jsonlite & flatten into list

view.sampID <- function(sampleID,sampleClass){
  encoded_sampleID <- URLencode(sampleID, reserved = TRUE)
  encoded_sampleClass <- URLencode(sampleClass, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/view?sampleTag=", encoded_sampleID,
              "&sampleClass=",encoded_sampleClass,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

view.uuid <- function(sampleUuid){
  encoded_sampleUuid <- URLencode(sampleUuid, reserved = TRUE)
  reqURL<-paste0("http://data.neonscience.org/api/v0/samples/view?sampleUuid=",encoded_sampleUuid,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

view.barcode <- function(sampleCode){
  encoded_sampleCode <- URLencode(sampleCode, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/view?barcode=",encoded_sampleCode,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

view.IGSN <- function(IGSN){
  encoded_IGSN <- URLencode(IGSN, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/view?archiveGuid=",encoded_IGSN,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}



## ---Sample Downloads Functions------------------------------------------------------------------------------------

download.sampID <- function(sampleID,sampleClass,degree){
  encoded_sampleID <- URLencode(sampleID, reserved = TRUE)
  encoded_sampleClass <- URLencode(sampleClass, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/download?sampleTag=",encoded_sampleID,
                 "&sampleClass=",encoded_sampleClass,"&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

download.uuid <- function(encoded_sampleUuid,degree){
  encoded_sampleUuid <- URLencode(sampleUuid, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/download?sampleUuid=",encoded_sampleUuid,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

download.barcode <- function(sampleCode,degree){
  encoded_sampleCode <- URLencode(sampleCode, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/download?barcode=",encoded_sampleCode,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}

download.IGSN <- function(IGSN,degree){
  encoded_IGSN <- URLencode(IGSN, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/samples/download?archiveGuid=",encoded_IGSN,
                 "&degree=",degree,"&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$sampleViews
  return(avail.data)
}


## ---Function to find location properties for a given location ID------------------------------------------------------------------------------------

view.locations <- function(locationID){
  encoded_locationID <- URLencode(locationID, reserved = TRUE)
  reqURL<-paste0("https://data.neonscience.org/api/v0/locations/",encoded_locationID,"?history=true&apiToken=",Neon_Token)
  req<-GET(reqURL)
  req.text <- content(req, as="text")
  avail <- jsonlite::fromJSON(req.text, 
                              simplifyDataFrame=T, 
                              flatten=T)
  avail.data<-avail$data$locationHistory
  return(avail.data)
}