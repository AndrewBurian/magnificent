#
# Monitor a URL continuously, providing
# reports on its availability in a log file
# and as a web page.
#


import json
import logging
import sys
from twisted.internet import task
from twisted.internet import reactor
from twisted.web import server, resource
import urllib2

config = {}
log = logging.getLogger(__name__)
checks = 0
successes = 0
failures = 0


def log_to_stderr(log):
    """ set up logging on standard error """
    format_str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    logging.basicConfig(stream=sys.stderr,
                        format=format_str,
                        level=logging.DEBUG)


def health_check():
    """ perform the health check for a URL """
    global config, log, checks, successes, failures
    request = urllib2.Request(config["url"])
    checks += 1
    try:
        response = urllib2.urlopen(request)
        log.info("%s is okay! (%s)", config["url"], response.getcode())
        successes += 1
    except urllib2.URLError, e:
        log.info("%s is ERROR! (%s)", config["url"], e)
        failures += 1


def generate_report():
    """ format a string with current report """
    report = "%i checks, %i failures, %.2f%% success rate"
    return report % (checks,
                     failures,
                     100 * float(successes)/checks)


def log_health_report():
    """ log the report """
    log.info("REPORT: " + generate_report())


class MonitorSite(resource.Resource):
    """ simple twisted site, gives the report out on the web """
    isLeaf = True

    def render_GET(self, request):
        return generate_report()


if __name__ == "__main__":
    log_to_stderr(log)
    config = json.loads(open("monitor_config.json", "rb").read())

    site = server.Site(MonitorSite())
    reactor.listenTCP(config["port"], site)
    log.info("Started site on port %i", config["port"])

    check_loop = task.LoopingCall(health_check)
    check_loop.start(config["url_frequency"])

    report_loop = task.LoopingCall(log_health_report)
    report_loop.start(config["report_frequency"])

    reactor.run()
