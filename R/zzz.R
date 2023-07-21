# Copyright © 2022 University of Kansas. All rights reserved.
#
# Creative Commons Attribution NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

pygt3x <- NULL

.onLoad <- function(libname, pkgname) {

  if(reticulate::py_module_available("pygt3x")){
    pygt3x <<- reticulate::import("pygt3x", delay_load = TRUE)
  }
}
