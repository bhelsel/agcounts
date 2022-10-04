#' @title agcounts: R Package for Extracting Actigraphy Counts from Accelerometer Data.
#'
#' @description This R Package reads the X, Y, and Z axes in a GT3X accelerometer file
#'     and converts it to Actigraphy counts. This work was inspired by Neishabouri et al.
#'     who published the article "Quantification of Acceleration as Activity Counts in
#'     ActiGraph Wearables on February 24, 2022. The \href{https://www.researchsquare.com/article/rs-1370418/v1}{link to the article}
#'     and Python implementation of this code \url{https://github.com/actigraph/agcounts}.
#'
#' @section agcounts functions:
#'
#' \code{\link{get_counts}}
#'
#' \code{\link{calculate_counts}}
#'
#' @docType package
#' @name agcounts
#' @importFrom read.gt3x read.gt3x
#' @import magrittr


#' @useDynLib agcounts, .registration = TRUE
#' @importFrom Rcpp sourceCpp

NULL
