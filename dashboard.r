library(RSQLite)
library(DBI)
library(ggplot2)
library(shiny)
library(leaflet)

#connection with the database
conn <- dbConnect(SQLite(), "database.db")
liiklusonnetus_df <- dbReadTable(conn, "liiklusonnetus")



ui <- fluidPage(
  # Paneeli pealkiri
  titlePanel("Liiklusõnnetuste jagunemine"),
  
  # Joonise kuvamise ala
  mainPanel(
    # Tabs
    tabsetPanel(
      # Tab 1
      tabPanel(
        title = "Tab 1",
        value = "tab1",
        fluidRow(
          column(
            width = 12,
            plotOutput("liiklusonnetused_jagunemine")
          )
        )
      ),
      
      # Tab 2
      tabPanel(
        title = "Tab 2",
        value = "tab2",
        fluidRow(
          column(
            width = 12,
            leafletOutput("kaart")
          )
        )
      )
    )
  )
)

# Defineerime serveriosa
server <- function(input, output) {
  
  output$liiklusonnetused_jagunemine <- renderPlot({
    # Loome tulpdiagrammi
    liiklusonnetused_jagunemine <- ggplot(liiklusonnetus_df, aes(x = Liiklusonnetuse_liik)) +
      geom_bar() +
      ylab("Liiklusõnnetuse liik") +
      xlab("Esinemiste arv") +
      ggtitle("Liiklusõnnetuste esinemine") +
      coord_flip()
    
    # Tagastame joonise
    liiklusonnetused_jagunemine
  })

  # Loome kaardi
  output$kaart <- renderLeaflet({
    kaart <- leaflet()

    kaart <- kaart %>%
      addTiles() %>%
      setView(lng = 25.0, lat = 58.6, zoom = 7)

    for (i in 1:nrow(liiklusonnetus_df)) {
     coordinates <- liiklusonnetus_df$coordinates[i]
      lat_lng <- strsplit(coordinates, ",")[[1]]
      lat <- as.numeric(lat_lng[1])
      lng <- as.numeric(lat_lng[2])
      liiklusonnetuse_liik <- liiklusonnetus_df$Liiklusonnetuse_liik[i]
      kaart <- addMarkers(kaart, lng = lng, lat = lat)
    }

    kaart
  })
}

# Käivitame Shiny rakenduse
shinyApp(ui = ui, server = server)

