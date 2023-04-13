.agPlotTheme <- function(){
  ggplot2::theme(
    axis.text = ggplot2::element_text(size = 14),
    axis.title.x = ggplot2::element_text(size = 18, face = "bold", margin = ggplot2::margin(t = 25)),
    axis.title.y = ggplot2::element_text(size = 18, face = "bold", margin = ggplot2::margin(r = 25)),
    plot.title = ggplot2::element_text(size = 24, face = "bold", margin = ggplot2::margin(t = 15, b = 15)))
}

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
