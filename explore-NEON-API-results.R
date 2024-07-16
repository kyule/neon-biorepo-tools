#### Explore results of NEON sample endpoint API results

# Call file with functions
source("/Users/kelsey/Github/neon-biorepo-tools/NEON-API-calls.R")

# Get data for a sample via different methods

NEON.BET.D01.000444.Class<-find.sampleClass("NEON.BET.D01.000444")
NEON000A1<-view.IGSN("NEON000A1")
NEON000A1.tree<-download.IGSN("NEON000A1",100)


