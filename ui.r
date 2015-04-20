library(shiny)
library(shinydashboard)
library(leaflet)
library(shinyGridster)

shinyUI(fluidPage(
  titlePanel("Portland 911 Dispatches"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      gridster(tile.width = 125, tile.height = 125,
        gridsterItem(col = 1, row = 1, size.x = 4, size.y = 2,
          leafletMap(
            "map", "100%", "100%",
            initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
            initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
            options=list(
            center = c(-122.6819, 45.52),
            zoom = 13
          )
        )
        )
      ),
      tableOutput("topCrimes"),
      tableOutput("topAgencies")
      )
  )
 )
)