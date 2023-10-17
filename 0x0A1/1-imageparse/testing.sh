#!/bin/bash

# Define color codes for formatting
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"
zip_file=0
delete_flag=0
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
    wget -q -P "$2" "$1" 
    if [ $? -ne 0 ]; then  #check if the download was successful
        printf "${RED}Failed to download: $1${NC}\n"
    else
        ((download_count++)) #count number of successful downloads
    fi
}

format_size()
{
    local size=$1
    local unit=("b" "Kb" "Mb" "Gb" "Tb")
    local unit_index=0
    while [ $size -ge 1024 ] && [ $unit_index -lt 4 ]; do
        size=$((size / 1024))
        ((unit_index++))
    done
    echo "$size${unit[$unit_index]}"
}

# Function to fetch image links from the provided URL
get_img_links()
{
		curl -s "$url" | grep -Eo "https://[^\"]*\.$imagetype" | sed "s/<[^>]\+//g"
}

# Check if zip_file is not 1, which means -z was not provided
if [[ $# -gt 0 ]]; then
	while getopts ":zad" opt;
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
			d) delete_flag=1
				;;

			*) printf "$OPTERR\n"; exit 1;;
		esac
	done
fi

if [ $delete_flag -eq 1 ] && ([ $zip_file -eq 1 ] || [ $alltype -eq 1 ]);then
	printf "${RED}-d option cannot be used in conjunction with -z or -a options. Exiting...${NC}\n"
	exit 1
fi

if [ $delete_flag -eq 1 ]; then
    printf "Deleting folders with downloaded images...\n"


folders=($(find . -maxdepth 1 -type d -exec sh -c '[ -n "$(find "{}" -maxdepth 1 -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.png")" ]' \; -print))

if [ ${#folders[@]} -eq 0 ]; then
    printf "No folders with downloaded image files found.\n"
    exit 0
fi

options=("Delete All Folders" "Exit")

# Generate dynamic folder numbering and options
for ((i = 0; i < ${#folders[@]}; i++)); do
    options+=("${folders[i]}")
done

printf "Folders with downloaded image files:\n"
select option in "${options[@]}"; do
    case $REPLY in
        1)
            echo "${folders[@]}" | xargs rm -r
            printf "All folders with downloaded image files deleted.\n"
            break
            ;;
        2)
            printf "Exiting the script.\n"
            exit 0
            ;;
        *)
            if [ "$REPLY" -ge 3 ] && [ "$REPLY" -le $((2 + ${#folders[@]} + 2)) ]; then
                selected_folder="${folders[$((REPLY - 3)) - 2]}"
                rm -r "$selected_folder"
                printf "Selected folder '$selected_folder' with downloaded image files deleted.\n"
                break
            else
                printf "Invalid option. Please select a valid option.\n"
            fi
            ;;
    esac
done

exit 0
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
	my_folder="alltype_${current_datetime}"
fi


# Download unique images
for link in ${unique_links}; do
	dwn_image "$link" "$my_folder"
done

printf "$download_count ${GREEN}$imagetype${NC} files have been downloaded to the directory ${GREEN}$my_folder${NC}\n"


# Create an associative array to store file names and sizes for sorting
declare -A file_sizes
max_name_length=0  # Initialize max_name_length to 0

# Calculate maximum column widths
for fname in "${sorted_files[@]}"; do
    fsize=${file_sizes["$fname"]}
    name_width=${#fname}
    size_width=${#fsize}

    # Update maximum column widths if needed
    if [ $name_width -gt $max_name_width ]; then
        max_name_width=$name_width
    fi
    if [ $size_width -gt $max_size_width ]; then
        max_size_width=$size_width
    fi
done

# Loop through the created directory and select file and file size
for file in "$my_folder"/*; do
	fname=$(basename "$file")
        fsize=$(du -b "$file" | cut -f 1)
        file_sizes["$fname"]=$fsize

        # Calculate the maximum file name length
        if [ ${#fname} -gt $max_name_length ]; then
            max_name_length=${#fname}
        fi
done

# Sort the associative array by file size in descending order
sorted_files=($(for key in "${!file_sizes[@]}"; do
    echo "$key:${file_sizes["$key"]}"
done | sort -t':' -k2 -rn | cut -d':' -f1))

# Calculate the total size of all downloaded image files
total_size=0
for fname in "${sorted_files[@]}"; do
    size=${file_sizes["$fname"]}
    total_size=$((total_size + size))
done

printf "${BLUE}FILE NAME%-${max_name_length}s FILE SIZE${NC}\n"
printf "%-${max_name_length}s %-${max_name_length}s\n" "$(printf -- '-%.0s' $(seq 1 $max_name_length))" "$(printf -- '-%.0s' $(seq 1 $(($max_name_length / 2))))"

# Display the sorted files and sizes
for fname in "${sorted_files[@]}"; do
    fsize=${file_sizes["$fname"]}
    fname_display=$(printf "%-${max_name_length}s" "$fname")  # Dynamic width, always 5 characters wider than the longest file name
    fsize_display=$(format_size "$fsize")
    printf "%s |  %s\n" "$fname_display" "$fsize_display"
done

# Display the total size
total_size_display=$(format_size "$total_size")
printf "${GREEN}Total Size: %-70s${NC}\n" "$total_size_display"


if [ ${zip_file} -eq 1 ]; then
	# Create a zip archive of downloaded images
	zip -q -r "$my_folder/$my_folder.zip" "$my_folder"
	printf "${GREEN}$download_count${NC} $imagetype files archived to ${GREEN}$my_folder.zip${NC} in the ${GREEN}$my_folder${NC} directory\n"
fi	

exit 0
