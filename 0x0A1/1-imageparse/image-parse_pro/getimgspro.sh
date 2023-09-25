#!/bin/bash

# Define color codes for formatting
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

# Initialize variables
zip_file=0
OPTERR="${RED}Invalid option or missing argument error - exiting ...${NC}"
url=""
imagetype=""
current_datetime=""
my_folder=""
download_count=0
img_types=("jpg" "jpeg" "gif" "png")

# Function to format file size in human-readable format
getsize()
{
    # Constants for size conversion
    let mb=1048576
    let kb=1024

    # Check file size and format accordingly
    if [[ $1 -ge $mb ]]; then
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024/1024}')Mb"
    elif [[ $1 -ge $kb ]]; then
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024}')Kb"
    else
        echo "$1b"
    fi
}

# Function to download an image
dwn_image()
{
    # Download an image using wget options for silencing wget and getting creating or directing it to the directory
    wget -q -P "$2" "$1" 
    if [ $? -ne 0 ]; then  #check if the download was successful
        printf "${RED}Failed to download: $1${NC}\n"
    else
        ((download_count++)) #count number of successful downloads
    fi
}

# Function to fetch image links from the provided URL
get_img_links()
{
    if [ $imagetype == "all" ]; then
        # Use curl to fetch the HTML content, then grep for image links with jpg, jpeg, gif, or png extensions
        curl -s "$url" | grep -Eo "https://[^\"]*\.(jpg|jpeg|gif|png)" | sed "s/<[^>]\+//g"
    else
        # Use curl to fetch the HTML content, then grep for image links only returning links that end with the specified image type
        curl -s "$url" | grep -Eo "https://[^\"]*\.$imagetype" | sed "s/<[^>]\+//g"
    fi
}

# Check if zip_file is not 1, which means -z was not provided
if [[ $# -gt 0 ]]; then
	while getopts ":za" opt;
	do
		case $opt in
			z) zip_file=1;;
            a) imagetype="all";;
			*) printf "$OPTERR\n"; exit 1;;
		esac
	done
fi

args=()
#Get any other argument provided that's not -z or -a and put it in an array
for arg in "$@"; do
	if [ "$arg" != "-z" ] && [ "$arg" != "-a" ]; then
		args+=("$arg")
	fi
done

#if any other argument is found the script will exit
if [ ${#args[@]} -gt 0 ]; then
	printf "${OPTERR}\n"; exit 1
fi

# Prompt the user for the URL and image type if -a is not specified
if [ -z "$imagetype" ]; then
    read -p "Enter a URL and image file type, e.g. http://somedomain.com jpg: " url imagetype
fi

# Trim leading/trailing whitespace from user input
url=$(echo "$url" | sed 's/^[ \t]*//;s/[ \t]*$//')
imagetype=$(echo "$imagetype" | sed 's/^[ \t]*//;s/[ \t]*$//')

# Validate user input and check for url and imagetype if they are present if not exit showing error
if [ -z "$imagetype" ] || [ -z "$url" ]; then
    printf "${RED}One or more arguments have not been provided. Exiting...${NC}\n"
    exit 1
elif ! [[ "${img_types[*]}" == *"$imagetype"* ]]; then
    printf "${RED}Unsupported image type entered. Exiting...${NC}\n"
    exit 1
fi

printf "Scanning for $imagetype images at $url\n"

# Call the method for getting links from url provided 
links=$(get_img_links)

#Exit and show error if no image was found
if [ -z "$links" ]; then
    printf "${RED}No $imagetype images found at the provided URL.${NC}\n"
    exit 1
fi

# Count the number of unique links and duplicates
img_found=$(echo "$links" | wc -l)
unique_links=$(echo "$links" | sort | uniq)
duplicate_count=$(echo "$links" | sort | uniq -d | wc -l)

printf "$img_found ${GREEN}$imagetype${NC} files detected at URL, which include ${RED}$duplicate_count${NC} duplicate(s)\n"

# Create a unique directory for storing downloaded images
current_datetime=$(date +'%Y_%m_%d_%H_%M_%S') #Use date time to the second so to always generate unique name of file
my_folder="${imagetype}_${current_datetime}" #create folder name

# Download unique images
for link in ${unique_links}; do
    dwn_image "$link" "$my_folder"
done

printf "$download_count ${GREEN}$imagetype${NC} files have been downloaded to the directory ${GREEN}$my_folder${NC}\n"

# Display a table of downloaded image files and their sizes
printf "${BLUE}FILE NAME                                          FILE SIZE${NC}\n"
printf "%-50s %-20s\n" "--------------------------------------------------" "--------------------"

#loop through the created directory and select file and file size
for file in "$my_folder"/*; do
    fname=$(basename "$file")
    if [ ${#fname} -gt 30 ]; then #If the name is longer than 30 characters trim it down to 30 fit the table
        fname=${fname:0:27}"..." 
    fi
    fsize=$(getsize $(du -b "$file" | cut -f 1))
    printf "%-50s |  %-20s\n" "$fname" "$fsize"
done

if [ ${zip_file} -eq 1 ]; then
    # Create a zip archive of downloaded images
    zip -q -r "$my_folder/$my_folder.zip" "$my_folder"
    printf "${GREEN}$download_count${NC} $imagetype files archived to ${GREEN}$my_folder.zip${NC} in the ${GREEN}$my_folder${NC} directory\n"
fi 

exit 0
