#!/bin/bash

#Student Name
#Student Number

 #To approach this task I first found out commands to read input from user
 #as it was important to get the file name. After which we check for the file
 #using the commands for checking if file exists in a directory or if file has content
 #the exit or continue of the conditions are met. The we proceed to read through each line
 #and in each line we go through the characters and check if they are allowed or disallowed
 #keeping track of the total characters and also the total allowed and disallowed characters
 #for each line and outputing them. After which we reset the variables and continue to the
 #line'

#Variables for storing characters

total_char_str=""
allowed_chars_str=""
disallowed_chars_str=""

#Prompt user to enter filename
echo "Enter the name of the candidate password file (including ext):"

#Read input from the user
read fname

#check if the file is not in the directory and exit with status 1 indicating error if it is not found
if ! [ -e "$fname" ]; then
	echo "File is not found: $fname"
	exit 1
#Check if the file is empty and exit with status of 1 indicating error if the file is empty
elif ! [ -s "$fname" ]; then
	echo "File not found: $fname"
	exit 1
else
	#Read each line of the file use default IFS
	while IFS= read -r line; do

		#Loop through each character in the line
		for ((i=0; i<${#line}; i++)); do
			character="${line:i:1}"
			total_char_str+="$character"

			#Check if the character is either a Capital letter, number or one of the special characters stated
			if [[ "$character" =~ [A-Z0-9*#!._-] ]]; then
				allowed_chars_str+="$character"
			else
				disallowed_chars_str+="$character"
			fi
		done

		#Getting the counts of the characters

		allowed_chars_count="${#allowed_chars_str}"
		disallowed_chars_count="${#disallowed_chars_str}"
		total_count=$((allowed_chars_count + disallowed_chars_count))

		echo "$total_char_str [T: $total_count] [A: $allowed_chars_str ($allowed_chars_count)] [D: $disallowed_chars_str ($disallowed_chars_count)]"

		#Reset the variables for the next line

		total_char_str=""
		allowed_chars_str=""
		disallowed_chars_str=""

	done < "$fname"
fi
