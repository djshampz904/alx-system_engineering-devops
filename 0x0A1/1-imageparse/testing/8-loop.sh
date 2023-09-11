#!/bin/bash

declare -a prof_array
prof_array=($USER, $HOME, $EUID, $HOSTNAME, $HOSTTYPE)

for i in "${prof_array[@]}"; do
	echo -n "The current value of "
	echo -n '$i'
	echo " is now $i"
done

exit 0
