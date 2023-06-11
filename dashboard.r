#Select all and ctrl+enter to run the code

library(RSQLite)
library(DBI)
library(ggplot2)
library(shiny)
library(leaflet)
library(DT)
library(lubridate)
library(plotly)

#connection with the database
conn <- dbConnect(SQLite(), "database.db")
liiklusonnetus_df <- dbReadTable(conn, "liiklusonnetus")
liiklusonnetus_df$Toimumisaeg <- as.Date(liiklusonnetus_df$Toimumisaeg)
#liiklusonnetus_df$distance <- as.numeric(liiklusonnetus_df$distance)
#liiklusonnetus_df$closest_feature <- as.character(liiklusonnetus_df$closest_feature)


ui <- navbarPage(
  # Paneeli pealkiri
  title = "Liiklusõnnetuste jagunemine",
  
  # Joonise kuvamise ala
  tabPanel(
    "Graafik & Tabel",
    fluidRow(
      column(
        width = 12,
        br(),
        sliderInput(
          "FILTER",
          "FILTER",
          min = min(liiklusonnetus_df$Toimumisaeg),
          max = max(liiklusonnetus_df$Toimumisaeg),
          value = c((max(liiklusonnetus_df$Toimumisaeg)-365), max(liiklusonnetus_df$Toimumisaeg))
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        plotlyOutput("liiklusonnetused_jagunemine"),
        br(),
        h2("Andmetabel"),
        dataTableOutput("tabel")
      )
    )
  ),
  
  tabPanel(
    "Kaart",
    fluidRow(
      column(
        width = 12,
        br(),
        sliderInput(
          "FILTER2",
          "FILTER2",
          min = min(liiklusonnetus_df$Toimumisaeg),
          max = max(liiklusonnetus_df$Toimumisaeg),
          value = c((max(liiklusonnetus_df$Toimumisaeg)-365), max(liiklusonnetus_df$Toimumisaeg))
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        leafletOutput("kaart")
      )
    )
  )
)

# Defineerime serveriosa
server <- function(input, output) {

output$liiklusonnetused_jagunemine <- renderPlotly({
  filtered_df <- liiklusonnetus_df[(as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER[1] & (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER[2], ]
 
  p <- ggplot(filtered_df, aes(x = Liiklusonnetuse_liik)) +
    geom_bar(fill = "#428bca") +
    ylab("Liiklusõnnetuse liik") +
    xlab("Esinemiste arv") +
    ggtitle("Liiklusõnnetuste esinemine") +
    coord_flip() +
    scale_y_continuous(expand = c(0, 0))

      ggplotly(p)

})


output$tabel <- renderDataTable({
  filtered_df <- liiklusonnetus_df[(as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER[1] & (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER[2], ]
  selected_cols <- setdiff(colnames(filtered_df), c("GPS_X", "GPS_Y", "Day", "Month", "Year", "Hour", "Minute", "Longitude", "Latitude"))  # Kustutatavate veergude nimetused
  datatable(filtered_df[, selected_cols, drop = FALSE], class = "compact hover", filter = "top")
})


  # Loome kaardi
output$kaart <- renderLeaflet({
  filtered_df <- liiklusonnetus_df[(as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER2[1] & (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER2[2], ]

  kaart <- leaflet()

  kaart <- kaart %>%
    addTiles() %>%
    setView(lng = 25.0, lat = 58.6, zoom = 7)

  for (i in 1:nrow(filtered_df)) {
    coordinates <- filtered_df$coordinates[i]
    lat_lng <- strsplit(coordinates, ",")[[1]]
    lat <- as.numeric(lat_lng[1])
    lng <- as.numeric(lat_lng[2])
    liiklusonnetuse_liik <- filtered_df$Liiklusonnetuse_liik[i]
    toimumisaeg <- filtered_df$Toimumisaeg[i]
    asula <- filtered_df$Asula[i]
    kaart <- addMarkers(kaart, lng = lng, lat = lat, popup = paste("Toimumisaeg:", toimumisaeg, "<br>",
                                                                  "Liiklusonnetuse liik:", liiklusonnetuse_liik, "<br>",
                                                                  "Asula:", asula))
  }

  kaart
})

}

# Käivitame Shiny rakenduse
shinyApp(ui = ui, server = server)