#Select all and ctrl+enter to run the code - if needed, uncomment the installation codes

#install.packages("RSQLite")
library(RSQLite)
#install.packages("DBI")
library(DBI)
#install.packages("ggplot2")
library(ggplot2)
#install.packages("shiny")
library(shiny)
#install.packages("leaflet")
library(leaflet)
#install.packages("DT")
library(DT)
#install.packages("lubridate")
library(lubridate)
#install.packages("plotly")
library(plotly)

#connection with the database
conn <- dbConnect(SQLite(), "database.db")
liiklusonnetus_df <- dbReadTable(conn, "liiklusonnetus")
liiklusonnetus_df$Toimumisaeg <- as.Date(liiklusonnetus_df$Toimumisaeg)


ui <- navbarPage(
  # Title
  title = "Liiklusõnnetuste jagunemine",
  
  # Tabs
  tabPanel(
    "Graafik & Tabel",
    fluidRow(
      column(
        width = 4,
        br(),
        sliderInput(
          "FILTER",
          "Õnnetuse toimumise aeg:",
          min = min(liiklusonnetus_df$Toimumisaeg),
          max = max(liiklusonnetus_df$Toimumisaeg),
          value = c((max(liiklusonnetus_df$Toimumisaeg)-365), max(liiklusonnetus_df$Toimumisaeg))
        )
      ),
       column(
        width = 4,
        br(),
      selectInput(
          "Liiklusonnetuse_liik",
          "Vali liiklusõnnetuse liik:",
          choices = unique(liiklusonnetus_df$Liiklusonnetuse_liik),
          multiple = TRUE,
          selected = unique(liiklusonnetus_df$Liiklusonnetuse_liik)
        )
      ),
      column(
        width = 4,
        br(),
      checkboxGroupInput(
          "Asula_valik",
          "Asula valik:",
          choices = unique(liiklusonnetus_df$Asula),
          selected = unique(liiklusonnetus_df$Asula)
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
        width = 4,
        br(),
        sliderInput(
          "FILTER2",
          "Õnnetuse toimumise aeg:",
          min = min(liiklusonnetus_df$Toimumisaeg),
          max = max(liiklusonnetus_df$Toimumisaeg),
          value = c((max(liiklusonnetus_df$Toimumisaeg)-365), max(liiklusonnetus_df$Toimumisaeg))
        )
      ),
       column(
        width = 4,
        br(),
      selectInput(
          "Liiklusonnetuse_liik2",
          "Vali liiklusõnnetuse liik:",
          choices = unique(liiklusonnetus_df$Liiklusonnetuse_liik),
          multiple = TRUE,
          selected = unique(liiklusonnetus_df$Liiklusonnetuse_liik)
        )
      ),
      column(
        width = 4,
        br(),
      checkboxGroupInput(
          "Asula_valik2",
          "Asula valik:",
          choices = unique(liiklusonnetus_df$Asula),
          selected = unique(liiklusonnetus_df$Asula)
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

# Server
server <- function(input, output) {

output$liiklusonnetused_jagunemine <- renderPlotly({
filtered_df <- liiklusonnetus_df[
  (as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER[1] & 
  (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER[2] &
  liiklusonnetus_df$Liiklusonnetuse_liik %in% input$Liiklusonnetuse_liik &
  liiklusonnetus_df$Asula == input$Asula_valik,
]
 
  p <- ggplot(filtered_df, aes(x = Liiklusonnetuse_liik)) +
    geom_bar(fill = "#428bca") +
    xlab("Liiklusõnnetuse liik") +
    ylab("Esinemiste arv") +
    ggtitle("Liiklusõnnetuste esinemine") +
    coord_flip() +
    scale_y_continuous(expand = c(0, 0))

      ggplotly(p)

})


output$tabel <- renderDataTable({
filtered_df <- liiklusonnetus_df[
  (as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER[1] & 
  (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER[2] &
  liiklusonnetus_df$Liiklusonnetuse_liik %in% input$Liiklusonnetuse_liik &
  liiklusonnetus_df$Asula == input$Asula_valik,
 ]
 
  selected_cols <- setdiff(colnames(filtered_df), c("GPS_X", "GPS_Y", "Day", "Month", "Year", "Hour", "Minute", "Longitude", "Latitude"))  # Kustutatavate veergude nimetused
  datatable(filtered_df[, selected_cols, drop = FALSE], class = "compact hover", filter = "top")
})


  # Map
output$kaart <- renderLeaflet({
filtered_df <- liiklusonnetus_df[
  (as.Date(liiklusonnetus_df$Toimumisaeg)) >= input$FILTER2[1] & 
  (as.Date(liiklusonnetus_df$Toimumisaeg)) <= input$FILTER2[2] &
  liiklusonnetus_df$Liiklusonnetuse_liik %in% input$Liiklusonnetuse_liik2 &
  liiklusonnetus_df$Asula == input$Asula_valik2,
]
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
                                                                  "Asula:", asula, "<br>"))
  }

  kaart
})

}

# Activate Shiny application
shinyApp(ui = ui, server = server)
