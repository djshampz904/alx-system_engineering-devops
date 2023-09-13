#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"
zip_file=0

OPTERR="${RED}Invalid option or missing argument error - exiting ...${NC}"

while getopts ':z' opt
do
        case $opt in
                z) zip_file=1;;

                :) zip_file=0;;

                *) printf "${OPTERR}\n"; exit 1;;
        esac
done

if [ $# -gt $((OPTIND - 1)) ]; then
        printf "${OPTERR}\n"; exit 1
fi

read -p "Enter a URL and image file type, e.g., http://somedomain.com jpg: " url imagetype

url=$(echo $url | sed 's/^[ \t]*//;s/[ \t]*$//')  # Remove leading/trailing whitespace
imagetype=$(echo $imagetype | sed 's/^[ \t]*//;s/[ \t]*$//')

if [ -z "$imagetype" ] || [ -z "$url" ]; then
        printf "${RED}One or more arguments have not been provided. Exiting...${NC}\n"
        exit 1
elif ! [[ "$imagetype" == "jpg" || "$imagetype" == "jpeg" || "$imagetype" == "gif" || "$imagetype" == "png" ]]; then
        printf "${RED}Unsupported image type entered. Exiting...${NC}\n"
        exit 1
fi

printf "Scanning for $imagetype at $url\n"

get_img_links()
{
        curl -s "$url" | grep -Eo "https://[^\"]*\.$imagetype" | sed "s/<[^>]\+//g"
}

links=$(get_img_links)

if [ -z "$links" ]; then
        printf "${RED}No images found${NC}\n"
        exit 1
fi

img_found=$(echo "$links" | wc -l)
unique_links=$(echo "$links" | sort | uniq)
duplicate_count=$(echo "$links" | sort | uniq -d | wc -l)

printf "$img_found ${GREEN}$imagetype${NC} files detected at URL, which include ${RED}$duplicate_count${NC} duplicate(s)\n"

current_datetime=$(date +'%Y_%m_%d_%H_%M_%S')
my_folder="${imagetype}_${current_datetime}"
download_count=0

dwn_image()
{
	wget -q -P $2 $1
	if [ $? -ne 0 ]; then
		printf "${RED}Failed to download: $1${NC}\n"

	else
		((download_count++))
	fi
}

for link in ${unique_links}; do
        dwn_image $link "$my_folder"
done

printf "$download_count $imagetype files have been downloaded to the directory ${GREEN}$my_folder${NC}\n"

if [ ${zip_file} -eq 1 ]; then
        zip -r "$my_folder/$my_folder.zip" $my_folder > /dev/null 2>&1
	printf "${GREEN}$download_count${NC} $imagetype files archived to ${GREEN}$my_folder.zip${NC} in the ${GREEN}$my_folder${NC} directory\n"
fi 


dir=$my_folder

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

printf "${BLUE}FILE NAME                                          FILE SIZE${NC}\n"
printf "%-50s %-20s\n" "--------------------------------------------------" "--------------------"

for file in "$dir"/*; do
        fname=$(basename $file)
	if [ ${#fname} -gt 30 ]; then
		fname=${fname:0:27}"..."
	fi
        fsize=$(getsize $(du -b $file | cut -f 1))
        printf "%-50s |  %-20s\n" "$fname" "$fsize"
done




exit 0

