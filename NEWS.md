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
