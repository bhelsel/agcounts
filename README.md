# agcounts

<br>

This R Package reads the X, Y, and Z axes in a GT3X accelerometer file and converts it to Actigraphy counts. This work was inspired by Neishabouri et al. who published the article "Quantification of Acceleration as Activity Counts in ActiGraph Wearables on February 24, 2022. Here are the links to the <a href = https://www.researchsquare.com/article/rs-1370418/v1>article</a> and <a href = https://github.com/actigraph/agcounts>Python implementation</a> of this code on GitHub.

<br>

### Install

##### Install the devtools package if it is not already installed

```r
install.packages("devtools")
```

##### Use the install_github function to download agcounts from GitHub

```r
devtools::install_github("bhelsel/agcounts")
```
##### Load the agcounts package

```r
library(agcounts)
```
<br>

### Reading Files

##### Convert and read in a single GT3X file to R

```r
path = "Full pathname to the GT3X file"

get_counts(path = path, frequency = 30, epoch = 60, write.file = FALSE, return.data = TRUE)
```

<br>

### Writing Files

##### Convert a single GT3X file to a CSV file

```r
path = "Full pathname to the GT3X file"

get_counts(path = path, frequency = 30, epoch = 60, write.file = TRUE, return.data = FALSE)
```

##### Convert multiple GT3X files to a CSV file

```r
folder = "Full pathname to the folder where the GT3X files are stored"

files = list.files(path = folder, pattern = ".gt3x", full.names = TRUE)

sapply(files, get_counts, frequency = 30, epoch = 60, write.file = TRUE, return.data = FALSE)
```

##### Speed up processing time by using the parallel package

```r
folder = "Full pathname to the folder where the GT3X files are stored"

files = list.files(path = folder, pattern = ".gt3x", full.names = TRUE)

cores <- parallel::detectCores()

Ncores <- cores - 1

cl <- parallel::makeCluster(Ncores)

doParallel::registerDoParallel(cl)

`%dopar%` <- foreach::`%dopar%`

foreach::foreach(i = files) %dopar% {
  get_counts(path = i, frequency = 30, epoch = 60, write.file = TRUE, return.data = FALSE)
}

parallel::stopCluster(cl)

```







