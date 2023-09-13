#!/bin/bash

dir=$1

getsize()
{
	let mb=1048576
	let kb=1024

	if [[ $1 -ge $mb ]]; then
		echo "$(echo $1 | awk '{printf "%.2f", $1/1024/1024}')Mb"
	elif [[ $1 -ge $kb ]]; then
		echo "$(echo $1 | awk '{printf "%.2f", $1/1024}')Kb"
	else
		echo "$1b"
	fi
}

echo "FILE NAME					         FILE SIZE"
printf "%-50s %-20s\n" "--------------------------------------------------" "--------------------"

for file in "$dir"/*; do
	fname=$(basename $file)
	fsize=$(getsize $(du -b $file | cut -f 1))
	printf "%-50s %-20s\n" "$fname" "$fsize"
done

