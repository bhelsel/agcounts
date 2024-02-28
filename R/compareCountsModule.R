# Copyright © 2022 University of Kansas. All rights reserved.

#' @title compareCountsModuleUI
#' @description UI for compareCountsModule
#' @noRd
#' @keywords internal

compareCountsModuleUI <- function(id){
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::fileInput(ns("agdFile"), "Choose the Matching AGD File", multiple = FALSE, accept = c(".agd")),
      shiny::selectInput(ns("axisCounts2"), "Count Axis", choices = c("Axis1", "Axis2", "Axis3", "Vector.Magnitude"), selected = "Vector.Magnitude"),
      shiny::checkboxInput(ns("agdBlandAltmanPlot"), "Bland Altman Plot?", value = TRUE),
      shiny::uiOutput(ns("rangeYBlandAltman")),
      shiny::textInput(ns("agdPlotColor"), "Plot Color (accepts color name or hex code)", value = "#000000"),
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        id = "comparisonTabset",
        shiny::tabPanel("Visualization",
                        shiny::plotOutput(ns("comparisonPlot"), width = "100%")),
        shiny::tabPanel("Data",
                        shiny::HTML("<h5>Differences between ActiGraph counts and agcounts</h5>"),
                        reactable::reactableOutput(ns("comparisonReactableTable")))
      )
    )
  )
}

#' @title compareCountsModuleServer
#' @description Server for compareCountsModuleServer
#' @noRd
#' @keywords internal

compareCountsModuleServer <- function(id, filteredData){
  shiny::moduleServer(id, function(input, output, session){

    # Dynamic UI ----
    # Dynamic UI components generated from the server
    output$rangeYBlandAltman <- shiny::renderUI({
      shiny::req(comparisonData(), input$agdBlandAltmanPlot)
      ad <- max(abs(comparisonData()$Difference))
      shiny::sliderInput(session$ns("rangeYBlandAltman"),
                         "Adjust the Y-Axis of the Bland Altman Plot",
                         min = -ad, max = ad, value = c(-ad, ad),
                         post = " counts", ticks = FALSE)
    })

    # Data Processing ----

    agdDataComparison <- shiny::reactive({
      shiny::req(input$agdFile)
      date2filter <- as.Date(filteredData()[1, "time"])
      agdData <- .read_agd(input$agdFile$datapath)
      filter <- ifelse(agdData[["filter"]] == "LowFrequencyExtension", TRUE, FALSE)
      epoch_length <- agdData[["epoch_length"]]
      data <- agdData[["data"]][as.Date(agdData[["data"]]$time) == date2filter, ]
      return(list(filter = filter, epoch_length = epoch_length, data = data))
    })

    comparisonData <- shiny::reactive({
      shiny::req(filteredData(), agdDataComparison())
      Average <- Difference <- NULL
      agd <- agdDataComparison()
      raw <- filteredData()[, 1:4]
      class(raw) <- "data.frame"
      agcounts <- calculate_counts(raw, epoch = agd[["epoch_length"]], lfe_select = agd[["filter"]], tz = "UTC")
      agcounts %<>% dplyr::select(time, input$axisCounts2) %>% `colnames<-`(c("time", "agcounts"))
      agd[["data"]] %<>% dplyr::select(time, input$axisCounts2) %>% `colnames<-`(c("time", "agd"))
      df <- merge(agcounts, agd[["data"]], by = "time")
      df$Difference <- df$agcounts - df$agd
      df$Average <- (df$agcounts + df$agd) / 2
      return(df)
    })

    # Visualization ----
    output$comparisonPlot <- shiny::renderPlot({
      hexFormat <- stringr::regex("^#([A-Fa-f0-9]{6})$")
      agdColor <- ifelse(input$agdPlotColor %in% grDevices::colors() | grepl(hexFormat, input$agdPlotColor), input$agdPlotColor, "#000000")
      df <- comparisonData()
      p <- ggplot2::ggplot(data = df) +
        ggplot2::geom_point(ggplot2::aes(x = agd, y = agcounts), color = agdColor) +
        ggplot2::labs(title = "ActiGraph counts vs. agcounts", x = "ActiGraph Counts from the AGD FIle", y = "agcounts") +
        ggplot2::theme_minimal() +
        .agPlotTheme()

      if(input$agdBlandAltmanPlot){
        p <- ggplot2::ggplot(data = df, ggplot2::aes(x = Average, y = Difference)) +
          ggplot2::geom_point(size = 1, color = agdColor) +
          ggplot2::geom_hline(yintercept = mean(df$Difference), color = "#000000", linewidth = 0.5) +
          ggplot2::geom_hline(yintercept = mean(df$Difference) - (1.96 * stats::sd(df$Difference)), color = "#000000", linewidth = 0.5, linetype = "dotted") +
          ggplot2::geom_hline(yintercept = mean(df$Difference) + (1.96 * stats::sd(df$Difference)), color = "#000000", linewidth = 0.5, linetype = "dotted") +
          ggplot2::coord_cartesian(ylim = input$rangeYBlandAltman) +
          ggplot2::labs(title = "ActiGraph counts vs. agcounts", x = "ActiGraph vs. agcounts Averages", y = "Differences") +
          ggplot2::theme_minimal() +
          .agPlotTheme()
      }
      return(p)
    }, res = 96)

    # Reactable Data Table ----
    output$comparisonReactableTable <- reactable::renderReactable({
      shiny::req(comparisonData())
      comparisonData <- comparisonData()
      comparisonData <- comparisonData[comparisonData$Difference != 0, ]
      reactable::reactable(
        data = comparisonData,
        columns = list(
          time = reactable::colDef(name = "time", minWidth = 125),
          agcounts = reactable::colDef(name = "agcounts", filterable = TRUE),
          agd = reactable::colDef(name = "agd", filterable = TRUE),
          Difference = reactable::colDef(name = "Difference", filterable = TRUE),
          Average = reactable::colDef(name = "Average", filterable = TRUE)),
        showPageSizeOptions = TRUE, pageSizeOptions = seq(5, 25, 5),
        defaultPageSize = 5, searchable = TRUE, striped = TRUE,
        highlight = TRUE, bordered = TRUE,
        theme = .agReactableTheme())
    })
  })
}

