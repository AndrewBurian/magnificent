from collections import deque
from functools import partial
import argparse

from urllib2 import HTTPError, URLError, urlopen
from twisted.web import server, resource
from twisted.internet import reactor
from twisted.internet.task import LoopingCall


def status(address):
    """
        If you get a proper response from address, return a 200
        If you get an HTTP error code, return that code (404, 500)
        If you get no connection, return 0
    """
    try:
        urlopen(address).read()
        return 200
    except HTTPError as http_error:
        return http_error.code
    except URLError:
        return 0


class Monitor(object):
    """
    The monitor manages a deque of recent results from the status_function,
    which it expects to be numerical HTTP status codes.
    """

    def __init__(self, status_function, verbose=False):
        self.verbose = verbose
        self.status_function = status_function
        self.status_cache = deque(maxlen=10)

    def loop(self):
        self.status_cache.append(self.status_function())
        if self.verbose:
            print self.status()

    def status(self):
        """
        Returns a string status for the monitored service.

        >>> m = Monitor(status_function=lambda:200)
        >>> m.loop()
        >>> m.loop()
        >>> m.loop()
        >>> m.status()
        'Error Rate: 0.0%'

        >>> m = Monitor(status_function=lambda:500)
        >>> m.loop()
        >>> m.loop()
        >>> m.loop()
        >>> m.status()
        'Error Rate: 100.0%'

        >>> m = Monitor(status_function=lambda:0)
        >>> m.loop()
        >>> m.loop()
        >>> m.loop()
        >>> m.status()
        'Magnificent is DOWN!'

        """
        if self.status_cache[-1] == 0:
            return "Magnificent is DOWN!"
        else:
            return "Error Rate: {}%".format(Monitor.error_rate(self.status_cache))

    @classmethod
    def error_rate(cls, list_of_statuses):
        """
        Returns the percentage of the list_of_statuses that aren't 200's

        >>> Monitor.error_rate([200,200,200,200,500])
        20.0
        >>> Monitor.error_rate([200])
        0.0
        >>> Monitor.error_rate([500])
        100.0
        >>> Monitor.error_rate([200,200,500,0])
        50.0

        """
        return len([x for x in list_of_statuses if x != 200])*1.0 / len(list_of_statuses) * 100


class Http(resource.Resource):
    """
    A simple HTTP endpoint that just returns the status from the Monitor object.
    """
    def __init__(self, monitor):
        resource.Resource.__init__(self)
        self.monitor = monitor

    isLeaf = True
    def render_GET(self, request):
        return self.monitor.status()


def run(interval=1, host="localhost", port=12345, service_port=12346, verbose=True):

    status_function = partial(status, address="http://{}:{}".format(host, port))
    monitor = Monitor(status_function=status_function, verbose=verbose)

    site = server.Site(Http(monitor=monitor))

    loopingcall = LoopingCall(monitor.loop)
    loopingcall.start(interval)

    reactor.listenTCP(service_port, site)
    reactor.run()


if __name__ == "__main__":

    # first we run the doctests, only if they pass do we continue to runtime
    import doctest
    failures, out_of = doctest.testmod()
    if failures == 0:
        parser = argparse.ArgumentParser(
            description="Repeatedly poke a server for its status. Report on health.")

        parser.add_argument('--interval', action='store', dest='interval', type=int, default=5 ,
                            help="The interval, in seconds, between http checks")
        parser.add_argument('--host', action='store', dest='host', default='localhost',
                            help="The host to run http checks against.")
        parser.add_argument('--port', action='store', dest='port', type=int, default=12345,
                            help="The port to run http checks against.")
        parser.add_argument('--service_port', action='store', dest='service_port', type=int, default=12346,
                            help="The port to serve our own http service on.")
        parser.add_argument('--verbose', action='store_true', dest='verbose', default=False)
        run(**vars(parser.parse_args()))
