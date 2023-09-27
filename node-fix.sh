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
rm -fr usr/versions/node-v18/include
rm -fr usr/versions/node-v18/share
# node is pure 64-bit
rm -f usr/lib/libgcc_s.*
rm -f usr/lib/libstdc++.so*

#
# modify MRSIZE
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$(($TSIZE+36))
MRSIZE=${TSIZE}M
