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
