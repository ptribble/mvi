#!/bin/sh
#
# avoid errors from attempting to use a non-existent /bin/cat to
# print out the motd
#
touch root/.hushlogin
