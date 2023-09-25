#!/bin/bash

# I employed key commands and techniques from Modules 1-8 to craft this script. 
# wget, curl, and sed work together to clean HTML content and extract image links.
# The getopts command manages options, allowing for zip archiving.
# User input is obtained via read, and formatting is enhanced using printf for colorful and organized output.
# Various if statements validate user inputs, ensuring the presence of required arguments and supported image types.
# awk is employed within the getsize function to convert file sizes into human-readable formats,
# facilitating the generation of a detailed report.
# The script utilizes loops (for and while) to iterate through image links and files.
# It also counts duplicates to enhance efficiency.
# Conditional statements guarantee proper execution and error handling throughout
# Lastly, the script features functions like dwn_image to eliminate code redundancy and maintain clarity.
# A dynamic naming scheme incorporates the current date and time, ensuring unique directories for each run.
# This integration of commands and techniques culminates in a robust script
# for downloading, reporting, and optionally archiving images from a given URL, offering user-friendliness and reliability.

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
alltype=0

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
		# Use curl to fetch the HTML content, then grep for image links only returning links that end with "." and the image type
		curl -s "$url" | grep -Eo "https://[^\"]*\.$imagetype" | sed "s/<[^>]\+//g"
}

# Check if zip_file is not 1, which means -z was not provided
if [[ $# -gt 0 ]]; then
	while getopts ":za" opt;
	do
		case $opt in
			z) zip_file=1;;
			a) alltype=1
				imagetype="("
				# Loop through the array and construct the string
				for type in "${img_types[@]}";
				do
					# Add each element to the string with '|' as a separator
					imagetype+="$type|"
				done
				# Remove the trailing '|' character from the string
				imagetype=${imagetype%|}
				imagetype+=")"
				;;

			*) printf "$OPTERR\n"; exit 1;;
		esac
	done
fi

echo "$imagetype";

args=()
#Get any other argument provided thats not -z and put it in an array
for arg in "$@"; do
	if [ "$arg" != "-z" ] && [ "$arg" != "-a" ]; then
		args+=("$arg")
	fi
done

#if any other argument is found the script will exit
if [ ${#args[@]} -gt 0 ]; then
	printf "${OPTERR}\n"; exit 1
fi

if ! [ $alltype -eq 1 ]; then
	# Prompt the user for the URL and image type
	read -p "Enter a URL and image file type, e.g. http://somedomain.com jpg: " url imagetype

	url=$(echo "$url" | sed 's/^[ \t]*//;s/[ \t]*$//')
	imagetype=$(echo "$imagetype" | sed 's/^[ \t]*//;s/[ \t]*$//')
else
	read -p "Enter a URL e.g. http://somedomain.com: " url

	url=$(echo "$url" | sed 's/^[ \t]*//;s/[ \t]*$//')
	imagetype=$imagetype
fi

# Validate user input and check for url and imagetype if they are present if not exit showing error
if [ -z "$imagetype" ] || [ -z "$url" ]; then
    printf "${RED}One or more arguments have not been provided. Exiting...${NC}\n"
    exit 1
elif ! [[ "${img_types[*]}" == *"$imagetype"* ]] && ! [[ $alltype -eq 1 ]]; then
    printf "${RED}Unsupported image type entered. Exiting...${NC}\n"
    exit 1
fi

if ! [ $alltype -eq 1 ];then
	printf "Scanning for $imagetype images at $url\n"
else
	printf "Scanning for $imagetype\n"
fi

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
if ! [ $alltype -eq 1 ]; then
	my_folder="${imagetype}_${current_datetime}" #create folder name
else
	jpg_folder="jpg_${current_datetime}"
	gif_folder="gif_${current_datetime}"
	jpeg_folder="jpeg_${current_datetime}"
	png_folder="png_${current_datetime}"
fi


# Download unique images
for link in ${unique_links}; do
	if ! [ $alltype -eq 1 ]; then
		dwn_image "$link" "$my_folder"
	else
		case "$link" in
			*.jpg) dwn_image "$link" "$jpg_folder"
				;;
			*.jpeg) dwn_image "$link" "$jpeg_folder"
				;;
			*.gif)dwn_image "$link" "$gif_folder"
				;;
			*.png)dwn_image "$link" "$png_folder"
				;;
        esac

	fi
done

printf "$download_count ${GREEN}$imagetype${NC} files have been downloaded to the directory ${GREEN}$my_folder${NC}\n"

# Display a table of downloaded image files and their sizes
printf "${BLUE}FILE NAME                                          FILE SIZE${NC}\n"
printf "%-50s %-20s\n" "--------------------------------------------------" "--------------------"

#loop through the created directory and select file and file size
if ! [ $alltype -eq 1 ]; then
	for file in "$my_folder"/*; do
		fname=$(basename "$file")
		if [ ${#fname} -gt 30 ]; then #If the name is longer than 30 characters trim it down to 30 fit the table
			fname=${fname:0:27}"..." 
		fi
		fsize=$(getsize $(du -b "$file" | cut -f 1))
		printf "%-50s |  %-20s\n" "$fname" "$fsize"
	done
else
	for folder_name in "$jpg_folder" "$gif_folder" "$jpeg_folder" "$png_folder";
	do
		if [ -d "$folder_name" ]; then
			for file in "$folder_name"/*;
			do
				fname=$(basename "$file")
				if [ ${#fname} -gt 30 ]; then
					fname=${fname:0:27}"..."
				fi
				fsize=$(getsize $(du -b "$file" | cut -f 1))
				printf "%-50s |  %-20s\n" "$fname" "$fsize"
			done
		fi
	done
fi

if [ ${zip_file} -eq 1 ]; then
	if ! [ $alltype -eq 1 ]; then
		# Create a zip archive of downloaded images
		zip -q -r "$my_folder/$my_folder.zip" "$my_folder"
		printf "${GREEN}$download_count${NC} $imagetype files archived to ${GREEN}$my_folder.zip${NC} in the ${GREEN}$my_folder${NC} directory\n"
	else
		for folder_name in "$jpg_folder" "$gif_folder" "$jpeg_folder" "$png_folder";
		do
			if [ -d "$folder_name" ]; then
				folder_type=$(basename "$folder_name")
				zip -q -r "$folder_name/$folder_name.zip" "$folder_name"
				printf "${GREEN}$download_count${NC} $folder_type files archived to ${GREEN}$folder_name.zip${NC} in the ${GREEN}$folder_name${NC} directory\n"

			fi
		done
	fi
fi	

exit 0
