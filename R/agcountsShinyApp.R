#' @title agShinyDeployApp
#' @description This function deploys the agcounts Shiny app.
#' @return No data or values are returned.
#' @details This function deploys the agcounts Shiny app for data visualization
#' and exploration. It also provides an opportunity to compare ActiGraph counts
#' generated from the agcounts package with those from ActiGraph's .agd files.
#' @param ... arguments passed to \code{\link[shiny]{shinyApp}}
#' @seealso
#'  \code{\link[shiny]{fluidPage}}, \code{\link[shiny]{titlePanel}}, \code{\link[shiny]{reexports}}, \code{\link[shiny]{shinyApp}}
#'  \code{\link[bslib]{bs_theme}}
#' @rdname agShinyDeployApp
#' @export
#' @import shiny
#' @import ggplot2
#' @importFrom bslib bs_theme

agShinyDeployApp <-function(...){
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

  shiny::shinyApp(ui, server, ...)
}

#' @title .agPlotTheme
#' @description Add a ggplot theme to the plots in agShiny
#' @noRd
#' @keywords internal

.agPlotTheme <- function(){
  ggplot2::theme(
    axis.text = ggplot2::element_text(size = 14),
    axis.title.x = ggplot2::element_text(size = 18, face = "bold", margin = ggplot2::margin(t = 25)),
    axis.title.y = ggplot2::element_text(size = 18, face = "bold", margin = ggplot2::margin(r = 25)),
    plot.title = ggplot2::element_text(size = 24, face = "bold", margin = ggplot2::margin(t = 15, b = 15)))
}

#' @title .agReactableTheme
#' @description Add a reactable theme to the tables in agShiny
#' @noRd
#' @keywords internal
#' @importFrom reactable reactableTheme
.agReactableTheme <- function(){
  theme = reactable::reactableTheme(
    color = "#000000",
    borderColor = "#133e7e",
    borderWidth = 2,
    stripedColor = "#bad6f9",
    highlightColor = "#7db0ea",
    cellPadding = "8px 12px",
    style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif"),
    searchInputStyle = list(width = "100%")
  )
}
