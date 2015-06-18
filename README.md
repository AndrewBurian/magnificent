# magnificent-monitor
The challenge has been met

## Completion time

 ~01:50:00 - Including learning Ruby as this is my first Ruby project

## Running the monitor

Requirements: ruby, run-parts

Command-line options:

`--server`,    `-s`   Specify the web address of the server (default: localhost)

--interval`,   `-i`   Specify the interval to check at in seconds (default: 15s)

`--port`,      `-p`   Specify the port to reach the server on (default: 12345)

`--warn`,      `-w`   Specify how many non-200 responses before a warning (default: 5)

`--log`,       `-l`   Specify a log file to output to

`--daemon`,    `-d`   Daemonize the program (Requires root)

`--quiet`,     `-q`   Do not print to stdout

`--kill`,      `-k`   Kill a running daemon (Requires root)

## Monitor as a daemon

Running the monitor with the `--daemon` flag will cause the monitor to run in the background.

If a monitor is already running as a daemon, invoking the monitor again will instead cause the daemon to output its current status.

To kill a running daemon, invoke the monitor with `--kill`

## Extending the monitor

For future enhancement, the monitor can be plugged into with any other scripts by placing them in the `hooks` directory

Scripts in `warn.d` are invoked when the warning limit has been reached (and multiples thereof)

Scripts in `fail.d` are invoked when the connection to the server is lost (only the first time)

Scripts in `resume.d` are invoked when the connection to the server is reestablished
