ui <- shiny::fluidPage(
  theme = bslib::bs_theme(bootswatch = "spacelab"),
  shiny::titlePanel("agcounts: An R Package to Calculate ActiGraph Counts"),
  shiny::h3("Import and Visualize Raw Acceleration Data"),
  rawDataModuleUI("rawDataModule"),
  shiny::h3("Calculate Counts"),
  countsModuleUI("countsModule"),
  shiny::h3("Compare Results to the an AGD File"),
  compareCountsModuleUI("compareCountsModule")
)

server <- function(input, output, session){
  filteredData <- rawDataModuleServer("rawDataModule")
  countsModuleServer("countsModule", filteredData)
  compareCountsModuleServer("compareCountsModule", filteredData)
}

shiny::shinyApp(ui, server)
