# Copyright © 2022 University of Kansas. All rights reserved.

#' @title rawDataModuleUI
#' @description UI for rawDataModuleUI
#' @noRd
#' @keywords internal

rawDataModuleUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::fileInput(ns("gt3xFile"), "Choose GT3X File", multiple = FALSE, accept = c(".gt3x")),
      shiny::radioButtons(ns("parser"), "Select your parser", choices = c("pygt3x", "GGIR", "read.gt3x", "agcalibrate"), inline = TRUE, selected = 0),
      shiny::uiOutput(ns("dateAccessed")),
      shiny::uiOutput(ns("timeSlot")),
      shiny::selectInput(ns("axisRaw"), "Raw Axis", choices = c("X", "Y", "Z", "Vector.Magnitude"), selected = "Y"),
      shiny::uiOutput(ns("applyRaw")),
      shiny::uiOutput(ns("applyEpoch")),
      shiny::HTML("<h5><b>Plot Settings for Raw Data</b></h5>"),
      shiny::textInput(ns("gt3xPlotColor"), "Plot Color (accepts color name or hex code)", value = "#000000"),
      shiny::uiOutput(ns("rangeXraw")),
      shiny::uiOutput(ns("rangeYraw"))
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        id = "rawTabset",
        shiny::tabPanel("Visualization",
                        shiny::plotOutput(ns("gt3xPlot"), width = '100%')),
        shiny::tabPanel("Data",
                        shiny::HTML("<h5> Average Raw Acceleration Data by Hour </h5>"),
                        reactable::reactableOutput(ns("rawReactableTable"))),
        shiny::tabPanel("Notes",
                        shiny::textOutput(ns("sampleFrequency")),
                        shiny::htmlOutput(ns("calibrationMethod")))
      )
    )
  )
}

#' @title rawDataModuleServer
#' @description Server for rawDataModuleServer
#' @noRd
#' @keywords internal

rawDataModuleServer <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    ns <- shiny::NS(id)

    # Increase file size capacity to handle GT3X files
    options(shiny.maxRequestSize=2000*1024^2)

    # Dynamic UI ----
    # Dynamic UI components generated from the server
    minDate <- shiny::reactive({ shiny::req(calibratedData()); as.Date(calibratedData()[1, "time"]) })
    maxDate <- shiny::reactive({ shiny::req(calibratedData()); as.Date(calibratedData()[nrow(calibratedData()), "time"]) })
    dates <- shiny::reactive({ shiny::req(minDate(), maxDate()); dates <- format(seq(minDate(), maxDate(), "day"), "%B %d, %Y")})


    output$dateAccessed <- shiny::renderUI({
      shiny::req(dates())
      shiny::selectInput(session$ns("dateAccessed"), "Choose a date", choices = dates(), selected = dates()[1])
    })

    output$timeSlot <- shiny::renderUI({
      shiny::req(calibratedData())
      shiny::radioButtons(session$ns("timeSlot"), "Choose AM or PM", choices = c("All Day", "AM", "PM"), selected = "All Day")
    })

    output$applyRaw <- shiny::renderUI({
      shiny::req(calibratedData(), input$axisRaw == "Vector.Magnitude")
      shiny::radioButtons(session$ns("applyRaw"),
                          "Apply Vector Magnitude Processing",
                          choices = c("Raw", "ENMO", "MAD"),
                          selected = "Raw",
                          inline = TRUE)
    })

    output$applyEpoch <- shiny::renderUI({
      shiny::req(calibratedData(), input$applyRaw %in% c("ENMO", "MAD"))
      shiny::sliderInput(session$ns("applyEpoch"),
                         "What epoch level?",
                         min = 1, max = 10, value = 5, step = 1,
                         post = " seconds", ticks = FALSE)
    })

    output$rangeXraw <- shiny::renderUI({
      shiny::req(filteredData())
      minTime <- filteredData()[1, "time"]
      maxTime <- filteredData()[nrow(filteredData()), "time"]
      shiny::sliderInput(session$ns("rangeXraw"),
                         "Select a range for the X axis",
                         value = c(minTime, maxTime),
                         min = minTime, max = maxTime,
                         timeFormat = "%H:%M:%S", timezone = "UTC", ticks = FALSE)
    })

    output$rangeYraw <- shiny::renderUI({
      shiny::req(filteredData())

      floor_dec <- function(x){ round(min(x) - 0.05, 1) }
      ceil_dec <- function(x){ round(max(x) + 0.05, 1) }

      minAcceleration <- floor_dec(filteredData()[input$axisRaw])
      maxAcceleration <- ceil_dec(filteredData()[input$axisRaw])

      if(!is.null(input$applyRaw)){
        if(input$applyRaw == "ENMO" | input$applyRaw == "MAD"){
          minAcceleration <- floor_dec(processedData()[input$applyRaw])
          maxAcceleration <- ceil_dec(processedData()[input$applyRaw])
        }
      }

      shiny::sliderInput(session$ns("rangeYraw"),
                         "Select a range for the Y axis",
                         value = c(minAcceleration, maxAcceleration),
                         min = minAcceleration,
                         max = maxAcceleration,
                         step = 0.1)
    })

    # Data Processing ----

    # Read in the data with the read.gt3x function
    rawData <- shiny::reactive({
      shiny::req(input$gt3xFile)
      read.gt3x::read.gt3x(input$gt3xFile$datapath, asDataFrame = TRUE)
    })

    # Read in the calibrated data with the read.gt3x function
    calibratedData <- shiny::reactive({
      shiny::req(input$gt3xFile, input$parser)
      if(input$parser == "agcalibrate") data <- agcalibrate(rawData())
      if(input$parser != "agcalibrate") data <- agread(path = input$gt3xFile$datapath, parser = input$parser)
      data$Vector.Magnitude <- sqrt(data$X^2 + data$Y^2 + data$Z^2)
      return(data)
    })

    # Filter data by dateAccessed to make processing faster
    filteredData <- shiny::reactive({
      shiny::req(calibratedData(), input$dateAccessed, input$timeSlot)
      date2filter <- as.Date(input$dateAccessed, "%B %d, %Y")
      data <- calibratedData()[as.Date(calibratedData()$time) == date2filter, ]

      valid_am <- any(unique(as.numeric(format(data$time, "%H"))) < 12)
      valid_pm <- any(unique(as.numeric(format(data$time, "%H"))) >= 12)

      if(input$timeSlot == "AM" & valid_am){
        time_slot <- "AM"
      } else if(input$timeSlot == "PM" & valid_pm){
        time_slot <- "PM"
      } else {
        time_slot <- "All Day"
      }

      data <-
        switch(
          time_slot,
          "All Day" = data,
          "AM" = data[as.numeric(format(data$time, "%H")) < 12, ],
          "PM" = data[as.numeric(format(data$time, "%H")) >= 12, ]
        )

      return(data)

    })

    processedData <- shiny::reactive({
      shiny::req(filteredData(), input$applyRaw %in% c("ENMO", "MAD"), input$applyEpoch)
      .calculate_raw_metrics(filteredData(), .get_frequency(filteredData()), input$applyEpoch)
    })



    # Visualization ----

    # Calibrated Data Plot
    output$gt3xPlot <- shiny::renderPlot({
      shiny::req(input$gt3xFile, input$parser, filteredData())
      .data <- NULL
      hexFormat <- stringr::regex("^#([A-Fa-f0-9]{6})$")
      gt3xColor <- ifelse(input$gt3xPlotColor %in% grDevices::colors() | grepl(hexFormat, input$gt3xPlotColor), input$gt3xPlotColor, "#000000")

      p <- filteredData() %>%
        ggplot2::ggplot(ggplot2::aes(x = time, y = .data[[input$axisRaw]])) +
        ggplot2::geom_line(color = gt3xColor) +
        ggplot2::coord_cartesian(xlim = input$rangeXraw, ylim = input$rangeYraw) +
        ggplot2::labs(title = "Line Graph of the Raw Acceleration Signal", x = "Time") +
        ggplot2::theme_minimal() +
        .agPlotTheme()

      if(!is.null(input$applyRaw)){
        if(input$applyRaw == "ENMO" | input$applyRaw == "MAD"){
          p <- processedData() %>%
            ggplot2::ggplot(ggplot2::aes(x = time, y = .data[[input$applyRaw]])) +
            ggplot2::geom_line(color = gt3xColor) +
            ggplot2::coord_cartesian(xlim = input$rangeXraw, ylim = input$rangeYraw) +
            ggplot2::labs(title = "Line Graph of the Raw Acceleration Signal", x = "Time") +
            ggplot2::theme_minimal() +
            .agPlotTheme()
        }
      }
      return(p)
    }, res = 96)


    # Reactable Data Table ----

    output$rawReactableTable <- reactable::renderReactable({
      shiny::req(filteredData())
      Hour <- X <- Y <- Z <- Vector.Magnitude <- NULL
      filteredData() %>%
        dplyr::mutate(Hour = format(time, "%H")) %>%
        dplyr::group_by(Hour) %>%
        dplyr::summarise(X = mean(X), Y = mean(Y), Z = mean(Z),
                         Vector.Magnitude = mean(Vector.Magnitude)) %>%
        dplyr::select(Hour, X, Y, Z, Vector.Magnitude) %>%
        dplyr::mutate_at(.vars = c(2:5), function(x) round(x, 2)) %>%
        reactable::reactable(columns = list(
          Hour = reactable::colDef("Hour", align = "center"),
          X = reactable::colDef("X-Axis", align = "center"),
          Y = reactable::colDef("Y-Axis", align = "center"),
          Z = reactable::colDef("Z-Axis", align = "center"),
          Vector.Magnitude = reactable::colDef("Vector Magnitude", align = "center")
        ),
        showPageSizeOptions = TRUE, pageSizeOptions = seq(5, 25, 5),
        defaultPageSize = 5, striped = TRUE, highlight = TRUE, bordered = TRUE,
        theme = .agReactableTheme())
    })



    # Notes ----

    output$sampleFrequency <- shiny::renderText({
      shiny::req(input$gt3xFile)
      sf <- .get_frequency(rawData())
      paste("The sample frequency is", sf, "Hertz.")
    })


    output$calibrationMethod <- shiny::renderUI({
      shiny::req(input$gt3xFile, input$parser)
      msgParser <-
        switch(input$parser,
               "pygt3x" = paste("<b><br>You chose the", input$parser, "parser.</b>", "<br>Description: Data is calibrated using the ActiGraph's pygt3x python module."),
               "GGIR" = paste("<b><br>You chose the", input$parser, "parser.</b>", "<br>Description: Data is read with the read.gt3x R package and calibrated with GGIR autocalibration."),
               "read.gt3x" = paste("<b><br>You chose the", input$parser, "parser.</b>", "<br>Description: Data is read with the read.gt3x R package."),
               "agcalibrate" = paste("<b><br>You chose the", input$parser, "parser.</b>", "<br>Description: Data is read with the read.gt3x R package and calibrated using a C++ version of the GGIR autocalibration."))
      shiny::HTML(msgParser)
    })

    return(filteredData)
  })
}
