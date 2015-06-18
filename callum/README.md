# PING THE THING
Ping the Thing monitors the health of an external web server by using Ruby's `Net::HTTP.get_response` to open a URL and
check the return code.  For now `200` is considered success and `500` is considered failure.

Possible extensions:
- add arrays for success and error codes in config to consider multiple response codes
- extend config file to contain configuration for monitoring multiple sites
  - multiple site monitoring could be implemented by creating a key:value store of site addresses to `PingTheThing` objects
  - take out the regular console logging (leave file logging) and add a forever loop to let users start and stop monitoring
  of each site, add commands like `list sites` to list all sites given in the config file, etc.
- external notification if failure rate goes above a certain percentage, set in config file 

# Configuration
The config file has the following format:
``` 
{
    "url": "http://localhost:12345",
    "pingFrequency": "2",
    "logFrequency": "5",
    "logName": "pingTheThing.log"
}```

`pingFrequency` is the amount of time, in seconds, you want to wait in betwen `get_response` calls  
`logFrequency` is the number of times you want to call `get_response` before logging

The above config would ping the `url` about every 2 seconds, and log after every 5 pings.

# Log File
The log file has the following format; containing entries with a timestamp, the number of failed requests, and the number of successful requests:
```
# Logfile created on 2015-06-17 20:09:22 -0700 by logger.rb/41954
2015-06-17 20:09:22 -0700: Monitoring started!
2015-06-17 20:09:30 -0700: Failed requests: 1, succesful requests: 4.
2015-06-17 20:09:40 -0700: Failed requests: 2, succesful requests: 8.
2015-06-17 20:09:50 -0700: Failed requests: 6, succesful requests: 9.
2015-06-17 20:10:00 -0700: Failed requests: 6, succesful requests: 14.
2015-06-17 20:10:10 -0700: Failed requests: 7, succesful requests: 18.
2015-06-17 20:10:11 -0700: Monitoring is stopping!
2015-06-17 20:10:11 -0700: Failed requests: 7, succesful requests: 18.
```