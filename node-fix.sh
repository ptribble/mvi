#!/bin/sh
cat > mvios.js <<EOF
var counter = 1;
var os = require('os');
var http = require('http');
http.createServer(function (request, response) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello from MVI\n\n");
    response.write("Request " + counter + "\n\n");
    response.end(JSON.stringify(os.cpus()));
    counter++;
}).listen(8000);
EOF

#
# modify MRSIZE
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$(($TSIZE+20))
MRSIZE=${TSIZE}M
