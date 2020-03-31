#!/bin/bash

printf "Content-type: text/plain\n\n"

printf "Attempting to restart the instance now...\n" $PATH_INFO

/var/run/s6/services/webserver/finish 1

exit 0