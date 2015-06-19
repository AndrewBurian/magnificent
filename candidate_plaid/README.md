# Magnificent Monitor

Monitor a URL continuously, providing reports on its availability in a log file and as a web page.

## Synopsis

    $ python monitor.py
    2015-06-16 17:10:25,983 - __main__ - INFO - Started site on port 54321
    2015-06-16 17:10:26,002 - __main__ - INFO - http://localhost:12345/ is okay! (200)
    2015-06-16 17:10:26,003 - __main__ - INFO - REPORT: 1 checks, 0 failures, 100.00% success rate
    2015-06-16 17:10:12,875 - __main__ - INFO - http://localhost:12345/ is okay! (200)
    2015-06-16 17:10:13,883 - __main__ - INFO - http://localhost:12345/ is ERROR! (HTTP Error 500: Internal Server Error)
    ...
    ... (many more lines) ...
    ...
    2015-06-16 17:10:13,890 - __main__ - INFO - REPORT: 539 checks, 125 failures, 76.81% success rate
      
Thereafter, you can follow along with the log, or have a look at `http://localhost:54321/` for the current
report.

## Configuration

The monitor is configured via a JSON file called `monitor_config.json`, located in the same 
directory as `monitor.py`. The keys in this file represent the following:

* `url`: the URL to fetch repeatedly.
* `url_frequency`: how many seconds to wait between fetches of the URL.
* `report_frequency`: how often to print a report line to the log.
* `port`: what port to run the web server on.

