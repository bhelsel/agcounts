# Copyright © 2022 University of Kansas. All rights reserved.

pygt3x <- NULL

.onLoad <- function(libname, pkgname) {

  if(reticulate::py_module_available("pygt3x")){
    pygt3x <<- reticulate::import("pygt3x", delay_load = TRUE)
  }
}
