#!/bin/sh
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2024 Peter Tribble
#

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
# the node binary itself is 107M, lib is about 12M
#
TSIZE=$(echo "$MRSIZE" | sed s:M::)
TSIZE=$((TSIZE+120))
MRSIZE=${TSIZE}M
