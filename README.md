# agcounts <img src="man/figures/agcounts.png" align="right" height="139" />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/agcounts)](https://CRAN.R-project.org/package=agcounts)
[![R-CMD-check](https://github.com/bhelsel/agcounts/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bhelsel/agcounts/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/bhelsel/agcounts/branch/master/graph/badge.svg)](https://app.codecov.io/gh/bhelsel/agcounts?branch=master)
<!-- badges: end -->

This R Package reads the X, Y, and Z axes in a GT3X accelerometer file and converts it to Actigraphy counts. This work was inspired by Neishabouri et al. who released a preprint of "Quantification of Acceleration as Activity Counts in ActiGraph Wearables" on February 24, 2022. Here are the links to the <a href = https://www.researchsquare.com/article/rs-1370418/v1>article</a> and <a href = https://github.com/actigraph/agcounts>Python implementation</a> of this code on GitHub.

<br>

### Install the `agcounts` package
```r
# Install the devtools package if it is not already installed
install.packages("devtools")

# Use the `install_github` function to download agcounts from GitHub
devtools::install_github("bhelsel/agcounts")
```
### Reading Files

##### Read in raw acceleration data and calculate ActiGraph counts

There are 3 ways to read in raw acceleration data using the `agcounts` package.
The preferred method is to use the calibrated reader from ActiGraph's 
<a href = https://github.com/actigraph/pygt3x>pygt3x</a> package. This requires
the user to ensure that Python version > 3.7 and < 3.9 is installed. The user 
can use the `reticulate` package to install python and the pygt3x package by
following these steps.

```r

library(reticulate)

# Install miniconda and restart your R session
reticulate::install_miniconda()

# Run py_config() to ensure that you have a python version available
# This will also initialize the r-reticulate virtual environment
py_config()

# Install pygt3x from Gitub using pip
py_install("pygt3x", pip = TRUE)

# Check to see if the pygt3x installation worked
py_list_packages()

```

You can also choose to use the `g.calibrate` function from the 
<a href=https://github.com/wadpac/GGIR>GGIR</a> package. No additional 
configuration is needed except for ensuring the GGIR package is installed.
Finally, the `read.gt3x::read.gt3x` can be used to read in uncalibrated data.
We include a S3 generic function within the `agcounts` package called `agread`
to implement these read methods. The preferred order if all readers are
functioning correctly is: 1) pygt3x, 2) `read.gt3x` to `g.calibrate`, and 
3) `read.gt3x` (uncalibrated). These are represented by the functions `agread.pygt3x`, 
`agread.ggir`, and `agread.gt3x`, respectively. They will be implemented in that
order if the `agread` S3 generic function is called.

### Calculate Counts

`calculate_counts` is the main function in the `agcounts` package.

##### Read and Convert a single GT3X file to ActiGraph counts

```r
# path = "Full pathname to the GT3X file", e.g.:

path = system.file("extdata/example.gt3x", package = "agcounts")

# Ensure that the r-reticulate virtual environment has been activated.
# This may not be necessary based on your Python configuration and how you installed the python packages.

reticulate::use_virtualenv("r-reticulate")

library(agcounts)

# Using the default pygt3x reader because pygt3x is installed
epochs <- 
  agread(path) %>%
  calculate_counts(epoch = 60)
  
# GGIR calibrated reader
epochs_ggir <- 
  agread.ggir(path) %>%
  calculate_counts(epoch = 60)
  
# Uncalibrated raw acceleration data
epochs_gt3x <-
  agread.gt3x(path) %>%
  calculate_counts(epoch = 60)

```

### Get Counts

The `get_counts` function is the wrapper function for `calculate_counts` that
also reads in the data using `agread` and one of the listed methods. 
See `sloop::s3_methods_generic("agread")`.

```r
path = system.file("extdata/example.gt3x", package = "agcounts")
get_counts(path = path, epoch = 60, write.file = FALSE, return.data = TRUE)
```

### Writing Files

##### Read and convert a single GT3X file to ActiGraph counts exported to a CSV file

We also offer a `write.file` argument that will read, convert, and export the
Actigraph count data to a CSV file in the same directory.

```r
# path = "Full pathname to the GT3X file", e.g.:
path = system.file("extdata/example.gt3x", package = "agcounts")

get_counts(path = path, epoch = 60, write.file = TRUE, return.data = FALSE)
```

##### Read and convert multiple GT3X files to ActiGraph counts exported a CSV file

We can extend the `write.file` argument by passing the path name of several GT3X
files to an `apply` function.

```r
folder = "Full pathname to the folder where the GT3X files are stored"

files = list.files(path = folder, pattern = ".gt3x", full.names = TRUE)

sapply(files, get_counts, epoch = 60, write.file = TRUE, return.data = FALSE)
```

To speed up processing time, the parallel package may be a useful addition to
the `write.file` argument. Here is sample code that can be adjusted based on 
each user's computer and R configurations.

```r
folder = "Full pathname to the folder where the GT3X files are stored"

files = list.files(path = folder, pattern = ".gt3x", full.names = TRUE)

cores = parallel::detectCores()

Ncores = cores - 1

cl = parallel::makeCluster(Ncores)

doParallel::registerDoParallel(cl)

`%dopar%` = foreach::`%dopar%`

foreach::foreach(i = files, .packages = "agcounts") %dopar% {
  get_counts(path = i, epoch = 60, write.file = TRUE, return.data = FALSE)
}

parallel::stopCluster(cl)

```
