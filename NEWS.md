# agcounts 0.6.9
* Added debugging capabilities to C++ code and additional arguments to control spherecrit, sdcriter, and minloadcrit within the `gcalibrateC` function. Thanks to John Muschelli for the contribution!

# agcounts 0.6.8
* Fix issue #20 related to C++ compiling by adding the `Rcpp` plugin for C++ 11.
* Update C++ code for `gcalibrateC` to resolve issue when there are NaN values in sphere data (issue #35)
* Resolve issue #36 when `calErrorEnd` never gets below 0.01.
* Change minloadcrit from 72 to 168 as recommended in issue #34

# agcounts 0.6.7
* Update `agcalibrate` to speed up function by first converting to a `data.table` before merging with the time stamps.
* Add parameter `imputeTimeGaps` to `agcalibrate` for users to decide if zeros are added back after calibration.

# agcounts 0.6.6
* Prepare agcounts for a CRAN submission
* Fix problem with `GGIR::g.calibrate` needing `GGIR::g.inspectfile` results.

# agcounts 0.6.5
* Update README.md file.
* Update code to allow interaction with data that is read into a tibble.
* Minor updates to the Shiny app

# agcounts 0.6.4
* Updated the agcounts license with KU Copyright and Creative Commons (CC BY-NC-SA 4.0).
* Changed the parsers to reflect the Python and R package names.
* Created more flexibility for adding a Shiny app theme.
* Extending the `.last_complete_epoch` function after discovering a file that did not find a complete epoch.


# agcounts 0.6.3
* Improved test coverage including tests for the Shiny Server
* Removed the Shiny App from the inst folder to only make it a callable app using `agShinyDeployApp`


# agcounts 0.6.2
* Update the Shiny rawDataModule UI and Server to filter by AM or PM to make plotting faster
* Improved test coverage from 19 to 56% by adding tests for the Shiny UI, `gcalibrateC`, `get_counts`, `agread`.
* Updated the test_actilife_counts.R file using a new data set that was uploaded for `gcalibrateC` testing.

# agcounts 0.6.1

* Added `start_time` and `stop_time` attributes to data read by the `pygt3x` calibrated reader.
* Added `lubridate::floor_date` to round data_start in case data doesn't start on the specified epoch.
* Updated Shiny app documentation by moving all `importFrom` documentation to the `agShinyDeployApp` function.
* Deployed the Shiny app to shinyapps.io and contained it in the inst/agcounts folder.

# agcounts 0.6.0

* Developed a Shiny app to allow users to visualize, explore, and compare activity counts.
* Added the `.calculate_raw_metrics` function to calculate ENMO and MAD for the Shiny App.
* Added the `.read_agd` function to extract metadata and data from the ActiGraph agd file for the Shiny app.
* Changed the use of the bitwise '&' with Boolean operands to '&&' in the gcalibrate.cpp file.
* Updated README.md with the new `agread` methods using the `parser` argument.


# agcounts 0.5.0

* Updated pygt3x python reader (ActiGraph removed the CalibratedReader class).
* Added a C++ version of the GGIR `g.calibrate` function called `agcalibrate` to be used within a piping structure with `calculate_counts`.
* Removed the agread S3 methods and replaced it with a switch statement.
* Added options for the user to choose a calibrated or uncalibrated parser.
* Removed test_calibrated_readers.R file since `agread.ggir` and `agread.pygt3x` are no longer used.
* Added codecov to the `agcounts` package.

# agcounts 0.4.0

* Added Github R-CMD-check workflow.
* Created a S3 generic function to extract and handle idle sleep time.
* Created a S3 generic function to read in the raw acceleration data using
  calibrated readers.
* Replaced a for loop in the `.resample` function with `Rcpp` to reduce 
  processing time.
* Added a package hexagon sticker and updated the README with the calibrated readers.
* Added a unit test to test the calibrated readers.

# agcounts 0.3.0

* Updated documentation for a new release
* Added Paul R. Hibbing as a package contributor.

# agcounts 0.2.4

* Added a unit test to ensure the agcounts package and Actilife counts match
* Added a unit test to check if the output of the algorithm is as expected
* Added testthat (>= 3.0.0) to the description file.

# agcounts 0.2.3

* Changed package namespace to include magrittr as an import
* Fixed the printing order of verbose by changing the magrittr's 
  pipe to eager pipe
* Added `dateTimeAs = "write.csv"` to the `data.table::fwrite` function
  to correctly display time stamps when data are exported to csv
* Moved all of the internal functions in agcounts to the helpers.R file

# agcounts 0.2.2

* Swapped in `min` in a place where `pmin` was incorrectly used

# agcounts 0.2.1

* Fixed automatic sampling frequency detection to remove assumption about
  file having >= 1000 rows

# agcounts 0.2.0

* Split `calculate_counts` out of `get_counts` to allow more flexible
  programming for end-users
* Moved the dot functions to internal
* Revised some of the logic for filling in missing timestamps during count
  extraction
* Revised some dealings with timezones to try making things more consistent
* Automated the detection of sampling frequency

# agcounts 0.1.0

* Initial release
