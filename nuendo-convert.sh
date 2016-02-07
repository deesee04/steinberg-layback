#!/bin/bash

## title: nuendo conversion for post production workflows
## description: watch a folder for audio output. perform a video layback with the newly created audio. 
## author: dc
## author_email: deesee04@gmail.com
## version: v.001
## date: 20160203

#########
## USER SECTION
## CHANGE THE SETTINGS BELOW

## this can be any unique string. initials work well.
user_string="user"

## email address to notify when conversion is completed. 
notify_email="email"

## directory in which to place renamed audio, relative to the export directory.
audio_dir="Bounces"

## directory in which to place converted video, relative to the export directory.
converted_dir="Laybacks"

## reverse folder depth. how many directories should we move BACK before we create the two defined above?
r_folder_depth=0

## version control document
vcs_name=".nuendo_convert_config"

##########
## SCRIPT
## NOT NOT CHANGE BELOW THIS LINE!
## (unless you really want to)

## helper function - create an array from a file
array_from_file() {
    items=() 
    while IFS= read -r line 
    do
        items+=("$line") 
    done < "$1"
}

## do stuff :(

received_event=$(xmllint --xpath 'string(//Path)' "$@")

if [ ! -e $received_event ]; then
	syslog -s -l error "ERROR: file not found or bad arguments."
	exit 1
fi

path=$(dirname "$received_event")

IFS='/' path_array=( $path )

path_length="${#path_array[@]}"

reverse=$(($path_length-$r_folder_depth-1))

if [ $r_folder_depth -gt $path_length ]; then
	syslog -s -l error "ERROR: folder depth"
	exit 1
fi  

position=1

while [ $position -le $reverse ]
do
	current_dir=${path_array[$position]}
	string+="/"$current_dir
	(( position++ ))
done

if [ "$string" = "" ]; then
	layback_path="/"
else
	layback_path=$string
fi

unset IFS

file=$received_event
today=$(date +"%Y%m%d")
filename=$(basename "$file")
filename_trunk="${filename%.*}"
filename_ext="${filename##*.}"
input_movie=$filename_trunk".mov"

if [ -e $path"/"$vcs_name ]; then
	array_from_file $path"/"$vcs_name
    ix=$( printf "%s\n" "${items[@]}" | grep -n -m 1 "^${filename_trunk}" | cut -d ":" -f1 )
    if [[ -z $ix ]]; then
        previous_version_count=0
    else
        index=$(( ix-1 ))
        newstring="${items[$index]}"
        breakstring=(${newstring//=/ })
        previous_version_count="${breakstring[1]}"
    fi
else
	previous_version_count=0
fi

new_version_count=$((previous_version_count+1))

output_filename=$filename_trunk"_"$user_string"."$new_version_count"_"$today".mov"

if [ ! -d $layback_path"/"$audio_dir ]; then
	mkdir $layback_path"/"$audio_dir
fi

if [ ! -d $layback_path"/"$converted_dir ]; then
	mkdir $layback_path"/"$converted_dir
fi

/usr/local/bin/ffmpeg -i $path"/"$input_movie -i $file -map 0:v -map 1:a -vcodec libx264 -pix_fmt yuv420p -acodec copy $layback_path"/"$converted_dir"/"$output_filename

mv $file $layback_path"/"$audio_dir"/"$filename_trunk"_"$user_string"."$new_version_count"_"$today"."$filename_ext

if [ -e $path"/"$vcs_name ] && [ $previous_version_count -eq 0 ]
	then
	  echo $filename_trunk"="$new_version_count >> $path"/"$vcs_name
elif [ -e $path"/"$vcs_name ]
	then
	  sed -i '' -e "s/${filename_trunk}.*/${filename_trunk}\=${new_version_count}/g" ${path}/${vcs_name}
else
	  echo $filename_trunk"="$new_version_count >> $path"/"$vcs_name
fi

echo "Conversion completed for: "$output_filename | mail -s "Nuendo Conversion Complete" $notify_email
