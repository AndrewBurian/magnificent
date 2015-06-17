
Curtis's Solution!
------------------

## Installation
 1. Install Python
 2. pip install twisted
 3. python monitor.py
 4. Okay, now you're running the monitor!

## Arguments!

You can type 'python monitor.py --help' for a list of arguments:

    usage: monitor.py [-h] [--interval INTERVAL] [--host HOST] [--port PORT]
                      [--service_port SERVICE_PORT] [--verbose]

    Repeatedly poke a server for its status. Report on health.

    optional arguments:
      -h, --help            show this help message and exit
      --interval INTERVAL   The interval, in seconds, between http checks
      --host HOST           The host to run http checks against.
      --port PORT           The port to run http checks against.
      --service_port SERVICE_PORT
                            The port to serve our own http service on.
      --verbose


