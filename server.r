library(shiny)
library(XML)
library(leaflet)
library(reshape2)
library(plyr)
library(shinydashboard)

#Grab xml data from City of Portland
dispatch = xmlInternalTreeParse("http://www.portlandonline.com/scripts/911incidents.cfm")

#Convert xml to data frame
dispatches = xmlToDataFrame(dispatch)

#Clean out garbage in the head
dispatches = dispatches[8:107,]
dispatches = dispatches[,6:11]

#Convert coordinate text to Lat/Lon columns
dispatchCoords = colsplit(dispatches$point, " ", names = c("Latitude", "Longitude"))
dispatches = cbind(dispatches, dispatchCoords)


#Parse data from summary
nameSplit <- strsplit(dispatches$summary, " at ")
contents = ldply(nameSplit)
colnames(contents) = c("CallType", "AddressAgency")
dispatches = cbind(dispatches, contents)
addressSplit <- strsplit(dispatches$AddressAgency, "\\[")
address = ldply(addressSplit)
colnames(address) = c("Address", "AgencyDrop")
dispatches = cbind(dispatches, address)
agencySplit <- strsplit(address$AgencyDrop, " \\#")
agency = ldply(agencySplit)
colnames(agency) = c("Agency", "ID")
agency$ID = substr(agency$ID, 1, nchar(agency$ID)-1)
dispatches = cbind(dispatches, agency)

#Remove unnecessary fields
dropVars = c("summary", "category", "point", "content", "AddressAgency", "AgencyDrop")
dispatches = dispatches[,!(names(dispatches) %in% dropVars)]

#Count most common crimes and most dispatched agencies
crimeCounts = arrange(as.data.frame(table(dispatches$CallType)), desc(Freq))
names(crimeCounts) = c("Call Type", "Frequency")
agencyCounts = arrange(as.data.frame(table(dispatches$Agency)), desc(Freq))
names(agencyCounts) = c("Agency", "Frequency")

shinyServer(function(input, output, session) {
  
  map = createLeafletMap(session, 'map')
  
  
  output$topCrimes <- renderTable({
    crimeCounts
  })
  output$topAgencies <- renderTable({
    agencyCounts
  })
  
  session$onFlushed(once=TRUE, function() {
    map$addMarker(dispatches$Longitude, dispatches$Latitude)
  })
})