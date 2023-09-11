#!/bin/bash

read -p "Enter a URL and image file type, e.g. http://somedomain.com jpg: " url imagetype
	
if [ -z "$imagetype" ] || [ -z "$url" ]; then
	echo "One or more arguments have not been provided.Exiting..."
	exit 1

elif ! [[ "$imagetype" == "jpg" || "$imagetype" == "jpeg" || "$imagetype" = "gif" || "$imagetype" = "png" ]]; then
        echo "Unsupported image type entered. Exiting..."
	exit 1
fi

echo -e "Scanning for $imagetype at $url"

current_datetime=$(date +'%Y_%m_%d_%H_%M')
my_folder="${imagetype}_${current_datetime}"


while IFS= read -r link;
do

	wget "$link" -P "$my_folder"

done < <(curl -s "$url" | grep -Eo '(http|https)://[^"]+' | grep -o "https://[^\"]*\.$imagetype")
