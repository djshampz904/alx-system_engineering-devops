#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
zip_file=0

OPTERR="${RED}Invalid option or missing argument error - exiting ...${NC}"

while getopts ':z' opt
do
	case $opt in
		z) zip_file=1;;

		:) zip_file=0;;

		*) echo -e "${OPTERR}"
		   exit 1;;
	esac
done

if [ $# -gt $((OPTIND - 1)) ]; then
	echo -e "${OPTERR}"
	exit 1
fi

read -p "Enter a URL and image file type, e.g. http://somedomain.com jpg: " url imagetype
	
if [ -z "$imagetype" ] || [ -z "$url" ]; then
	echo "${RED}One or more arguments have not been provided.Exiting...${NC}"
	exit 1

elif ! [[ "$imagetype" == "jpg" || "$imagetype" == "jpeg" || "$imagetype" = "gif" || "$imagetype" = "png" ]]; then
        echo "${RED}Unsupported image type entered. Exiting...${NC}"
	exit 1
fi

echo -e "Scanning for $imagetype at $url"

current_datetime=$(date +'%Y_%m_%d_%H_%M')
my_folder="${imagetype}_${current_datetime}"

while IFS= read -r link;
do

	wget -q "$link" -P "$my_folder"

done < <(curl -s "$url" | grep -Eo '(http|https)://[^"]+' | grep -o "https://[^\"]*\.$imagetype")
