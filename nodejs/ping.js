var request = require('request');

var fail = 0, total = 0;
var interval = 1000; // in ms, how often do we sample Magnificent?
var start = new Date();

console.log('Starting up ping service w/ frequency ' + (interval/1000) + 's...');
// Issue a request every second.
setInterval(function() {
    console.log('Ping!');
    request('http://localhost:12345', function(error, response, body) {
        total++;
        if (error || (response && response.statusCode != 200)) {
            fail++;
            console.log('Doink!');
        } else {
            console.log('Pong!');
        }
    });
}, interval);

process.on('SIGINT', process.exit);
process.on('exit', function() {
    var end = new Date();
    var time = (end - start)/1000;
    console.log('\nTotal pings:', total);
    console.log('Total time spent pinging: ' + time + 's');
    console.log('Uninspiring failures:', fail);
    console.log('Success rate:', 1-(fail/total));
    console.log('Failures per second:', fail/time);
});
