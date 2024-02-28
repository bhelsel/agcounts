# Copyright © 2022 University of Kansas. All rights reserved.

#' @title get_counts
#' @description Main function to extract counts from the Actigraph GT3X Files.
#' @param path Full path name to the GT3X File
#' @param epoch The epoch length for which the counts should be summed.
#' @param lfe_select Apply the Actigraph Low Frequency Extension filter, Default: FALSE
#' @param write.file Export a CSV file of the counts, Default: FALSE
#' @param return.data Return the data frame to the R Global Environment, Default: TRUE
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @param tz the desired timezone, Default: \code{UTC}
#' @param parser The parser to use when reading in the data. Parser values include pygt3x, GGIR, and read.gt3x options.
#' @param ... arguments passed to \code{\link[data.table]{fwrite}}
#' @return Writes a CSV file if write.file is TRUE and returns a data.frame if return.data is TRUE
#' @details Main function to extract counts from the Actigraph GT3X Files.
#' @seealso
#'  \code{\link[read.gt3x]{read.gt3x}}
#' @examples
#'  get_counts(
#'   path = system.file("extdata/example.gt3x", package = "agcounts"),
#'   epoch = 60, lfe_select = FALSE,
#'   write.file = FALSE, return.data = TRUE
#'   )
#' @export

get_counts <- function(
  path, epoch, lfe_select = FALSE, write.file = FALSE,
  return.data = TRUE, verbose = FALSE, tz = "UTC",
  parser = c("pygt3x", "GGIR", "read.gt3x"), ...
){

  if(verbose){
    print(paste0("------------------------- ", "Reading ActiGraph GT3X File for ", basename(path), " -------------------------"))
  }

  parser <- match.arg(parser)

  epoch_counts <- agread(path = path, verbose = verbose, parser = parser) %>%
    calculate_counts(epoch, lfe_select, tz, verbose)

  if(write.file){
    if(lfe_select){name <- paste0("AG ", epoch, "s", " LFE ", "Epoch Counts")}
    if(!lfe_select){name <- paste0("AG ", epoch, "s", " Epoch Counts")}
    out_dir <- file.path(dirname(path), name)
    if(!dir.exists(out_dir)) dir.create(out_dir)
    data.table::fwrite(
      epoch_counts,
      file.path(out_dir, gsub(".gt3x$", ".csv", basename(path))),
      dateTimeAs = "write.csv",
      ...
    )
  }

  if(return.data) return(epoch_counts) else invisible()

}

