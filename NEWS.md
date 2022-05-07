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
