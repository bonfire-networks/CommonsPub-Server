#!/bin/bash

printf "Content-type: text/plain\n\n"

printf "Attempting to restart the instance now...\n" $PATH_INFO

kill 7

exit 0