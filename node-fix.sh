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
# we don't need all of this
#
rm -fr usr/versions/node-v4/include
rm -fr usr/versions/node-v4/share
# assume a 32-bit node binary
rm -f usr/lib/amd64/libgcc_s.*
rm -f usr/lib/amd64/libstdc++.so*

#
# modify MRSIZE
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$(($TSIZE+32))
MRSIZE=${TSIZE}M
