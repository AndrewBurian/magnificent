# magnificent
A new challenger appears!

## Installation

 1. Install Python
 2. pip install twisted
 3. python server.py
 4. Okay, now you're running magnificent!
 5. Visit http://localhost:12345 in a web browser or something.
 6. It should throw a verbose error, or return "Magnificent!".

## Now it's your turn.

Magnificent fails 25% of the time.

We want to write a service to monitor the health of Magnificent Server externally.
We want the service to run continuously, and check Magnificent Server at least
once every 15 seconds. We want to know if it has thrown a non-200-OK response
in the past minute, and we especially want to know if the service is no longer
responding to requests. This service needs some method of outputting the status
of Magnificent Server.

In the future, we may want to expand our Magnificent Monitor to potentially e-mail us
when Magnificent Server fails too often or keep historical data - but not yet.
