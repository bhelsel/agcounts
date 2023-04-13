#' @title countsModuleUI
#' @description UI for countsModuleUI
#' @noRd
#' @keywords internal

countsModuleUI <- function(id){
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::sliderInput(ns("epoch"), "What epoch level?", min = 1, max = 60, value = 30, step = 1, post = " seconds", ticks = FALSE),
      shiny::checkboxInput(ns("lfe"), "Add a low frequency extension filter?", value = FALSE),
      shiny::HTML("<h5><b>Plot Settings for Calculate Counts</b></h5>"),
      shiny::selectInput(ns("axisCounts"), "Counts Axis", choices = c("Axis1", "Axis2", "Axis3", "Vector.Magnitude"), selected = "Vector.Magnitude"),
      shiny::checkboxInput(ns("excludeZeros"), "Exclude zeros from the plot?", value = FALSE),
      shiny::numericInput(ns("binwidthCounts"), "Select a frequency polygon binwidth", value = 30, step = 10),
      shiny::textInput(ns("countsPlotColor"), "Plot Color (accepts color name or hex code)", value = "#000000"),
      shiny::sliderInput(ns("rangeCounts"), "Select a range for the X axis", value = c(0, 2000), min = 0, max = 10000, post = " counts")
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        id = "countsTabset",
        shiny::tabPanel("Visualization",
                        shiny::plotOutput(ns("countsPlot"), width = "100%")),
        shiny::tabPanel("Data",
                        shiny::HTML("<h5>Total and average accelerometer counts from agcounts</h5>"),
                        reactable::reactableOutput(ns("countsReactableTable")))
      )
    )
  )
}

#' @title countsModuleServer
#' @description Server for countsModuleServer
#' @noRd
#' @keywords internal

countsModuleServer <- function(id, filteredData){
  shiny::moduleServer(id, function(input, output, session){

    # Data Processing ----
    calculatedCounts <- shiny::reactive({
      shiny::req(filteredData())
      raw <- filteredData()[, 1:4]
      class(raw) <- "data.frame"
      calculate_counts(raw, input$epoch, lfe_select = input$lfe, tz = "UTC")
    })

    # Visualization ----
    output$countsPlot <- shiny::renderPlot({
      shiny::req(calculatedCounts())
      .data <- NULL
      countData <- calculatedCounts()
      hexFormat <- stringr::regex("^#([A-Fa-f0-9]{6})$")
      color <- input$countsPlotColor
      defaultColor <- "#000000"
      countsColor <- ifelse(color %in% grDevices::colors() | grepl(hexFormat, color), color, defaultColor)
      if(input$excludeZeros) countData <- countData[countData[, input$axisCounts] > 0, ]
      ggplot2::ggplot(data = countData, ggplot2::aes(x = .data[[input$axisCounts]])) +
        ggplot2::geom_histogram(binwidth = input$binwidthCounts, fill = countsColor, color = "black") +
        ggplot2::coord_cartesian(xlim = input$rangeCounts) +
        ggplot2::labs(title = "Histogram of ActiGraph Counts", y = "Frequency") +
        ggplot2::theme_minimal() +
        .agPlotTheme()
    }, res = 96)

    # Reactable Data Table ----
    output$countsReactableTable <- reactable::renderReactable({
      shiny::req(calculatedCounts())
      Date <- NULL
      calculatedCounts() %>%
        dplyr::mutate(Date = as.Date(time)) %>%
        dplyr::group_by(Date) %>%
        dplyr::summarise(sAxis1 = sum(Axis1), mAxis1 = round(mean(Axis1)),
                         sAxis2 = sum(Axis2), mAxis2 = round(mean(Axis2)),
                         sAxis3 = sum(Axis3), mAxis3 = round(mean(Axis3)),
                         sVM = sum(Vector.Magnitude), mVM = round(mean(Vector.Magnitude))) %>%
        reactable::reactable(columns = list(
          Date = reactable::colDef(name = "Date", minWidth = 125, align = "center"),
          sAxis1 = reactable::colDef(name = "Sum", align = "center"),
          mAxis1 = reactable::colDef(name = "Mean", align = "center"),
          sAxis2 = reactable::colDef(name = "Sum", align = "center"),
          mAxis2 = reactable::colDef(name = "Mean", align = "center"),
          sAxis3 = reactable::colDef(name = "Sum", align = "center"),
          mAxis3 = reactable::colDef(name = "Mean", align = "center"),
          sVM = reactable::colDef(name = "Sum", align = "center"),
          mVM = reactable::colDef(name = "Mean", align = "center")
        ),
        columnGroups = list(
          reactable::colGroup(name = "Axis 1", columns = c("sAxis1", "mAxis1")),
          reactable::colGroup(name = "Axis 2", columns = c("sAxis2", "mAxis2")),
          reactable::colGroup(name = "Axis 3", columns = c("sAxis3", "mAxis3")),
          reactable::colGroup(name = "Vector Magnitude", columns = c("sVM", "mVM"))
          ),
          showPageSizeOptions = TRUE, pageSizeOptions = seq(5, 25, 5),
          defaultPageSize = 5, searchable = TRUE, striped = TRUE,
          highlight = TRUE, bordered = TRUE,
          theme = .agReactableTheme())
    })
  })
}








