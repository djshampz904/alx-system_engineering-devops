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

read -p "Enter a URL and image file type, e.g., http://somedomain.com jpg: " url imagetype

url=$(echo $url | sed 's/^[ \t]*//;s/[ \t]*$//')  # Remove leading/trailing whitespace
imagetype=$(echo $imagetype | sed 's/^[ \t]*//;s/[ \t]*$//')

if [ -z "$imagetype" ] || [ -z "$url" ]; then
        echo "${RED}One or more arguments have not been provided. Exiting...${NC}"
        exit 1
elif ! [[ "$imagetype" == "jpg" || "$imagetype" == "jpeg" || "$imagetype" == "gif" || "$imagetype" == "png" ]]; then
        echo "${RED}Unsupported image type entered. Exiting...${NC}"
        exit 1
fi

echo -e "Scanning for $imagetype at $url"

get_img_links()
{
        curl -s "$url" | grep -Eo "https://[^\"]*\.$imagetype" | sed 's/<[^>]\+//g'
}

links=$(get_img_links)

if [ -z "$links" ]; then
        echo "${RED}No images found${NC}"
        exit 1
fi

img_found=$(echo "$links" | wc -l)
unique_links=$(echo "$links" | sort | uniq)
duplicate_count=$(echo "$links" | sort | uniq -d | wc -l)

echo "$img_found $imagetype files detected at URL, which include $duplicate_count duplicate(s)"

current_datetime=$(date +'%Y_%m_%d_%H_%M')
my_folder="${imagetype}_${current_datetime}"
download_count=0

dwn_image()
{
        wget -q -P $2 $1
        if [ $? -ne 0 ]; then
            echo "${RED}Failed to download: $1${NC}"
        else
            ((download_count++))
        fi
}

for link in ${unique_links}; do
        dwn_image $link "$my_folder"
done

echo "Download completed: $download_count $imagetype files have been downloaded to the directory $my_folder"

if [ ${zip_file} -eq 1 ]; then
        myzip="zip -r $my_folder $my_folder"
fi

exit 0

