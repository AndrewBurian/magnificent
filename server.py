from random import choice

from twisted.web import server, resource
from twisted.internet import reactor


class Uninspiring(Exception):
    pass


class Magnificent(resource.Resource):
    isLeaf = True
    def render_GET(self, request):
        if choice([True, True, True, False]):
            return "Magnificent!"
        else:
            raise Uninspiring()


class run():
    site = server.Site(Magnificent())
    reactor.listenTCP(12345, site)
    reactor.run()


if __name__ == "__main__":
    run()
