from random import choice

from twisted.web import server, resource
from twisted.internet import reactor, task
import logging
import urllib2
import sys

success = 0
fail = 0
times = 0
server2check = ""
port = ""
log = logging.getLogger(__name__)

def server_check():
    global success, fail, times, server2check, host, port
    host = server2check if port == "" else server2check + ":" + port
    request = urllib2.Request(host)
    times += 1
    try:
        res = urllib2.urlopen(request)
        success += 1
        log.info("Magnificent responding magnificently on %s", host)
    except urllib2.URLError, e:
        fail += 1
        log.info("Magnificent not responding on %s", host)
    final_report()

def final_report():
    log.info("Server pinged %d times, %d successes and %d failures", times, success, fail)

class CheckServer(resource.Resource):
    isLeaf = True

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

    # it needs at least one parameter for the url to ping
    if len(sys.argv) == 1:
        sys.exit("No arguments. Correct call is: python server-check.py <host> <port>")

    server2check = sys.argv[1]
    if len(sys.argv) > 2:
        port = sys.argv[2]

    log.info("running server")
    site = server.Site(CheckServer())
    reactor.listenTCP(1234, site)

    check = task.LoopingCall(server_check)
    check.start(15)

    reactor.run()

