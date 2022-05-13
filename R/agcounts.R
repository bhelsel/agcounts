#' @title agcounts: R Package for Extracting Actigraphy Counts from Accelerometer Data.
#'
#' @description This R Package reads the X, Y, and Z axes in a GT3X accelerometer file and converts it to Actigraphy counts. This work was inspired by Neishabouri et al. who published the article "Quantification of Acceleration as Activity Counts in ActiGraph Wearables on February 24, 2022. The link to the article (https://www.researchsquare.com/article/rs-1370418/v1) and Python implementation of this code (https://github.com/actigraph/agcounts).
#'
#' @section agcounts functions:
#'
#' \code{\link{get_counts}}
#'
#' @docType package
#' @name agcounts
#' @importFrom read.gt3x read.gt3x
#' @importFrom magrittr %>% %<>% %T>%
NULL
