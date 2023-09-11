#!/bin/bash

read -p "Enter temperature file name: " file

file=week_data.csv
declare result=0
declare weekcount=1

while IFS= read -r line;
do
	IFS=,
	fields=($line)
	week_sum=0

	for field in ${fields[@]};
	do
		if [[ $field =~ ^[0-9]+$ ]]; then
			week_sum=$((week_sum + $field))
		fi
	done

	average=$(echo "scale=2; $week_sum / 7" | bc)
	echo "Week $weekcount average is $average"

	weekcount=$((weekcount + 1))

done < <(tail -n +2 "$file")

