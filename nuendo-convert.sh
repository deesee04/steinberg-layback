#!/bin/bash

## title: nuendo conversion for post production workflows
## description: watch a folder for audio output. perform a video layback with the newly created audio. 
## author: dc
## author_email: deesee04@gmail.com
## version: v.001
## date: 20160205

#########
## USER SECTION
## CHANGE THE SETTINGS BELOW

## this can be any unique string. initials work well.
user_string="<userstring"

## email address to notify when conversion is completed. 
notify_email="<email address>"

## directory in which to place renamed audio, relative to the export directory.
audio_dir="../Bounces"

## directory in which to place converted video, relative to the export directory.
converted_dir="../Laybacks"

## version control document
vcs_name=".nuendo_convert_config"

##########
## SCRIPT
## NOT NOT CHANGE BELOW THIS LINE!
## (unless you really want to)

array_from_file() {
    my_array=() 
    while IFS= read -r line 
    do
        my_array+=("$line") 
    done < "$1"
}

file="$@"
today=$(date +"%Y%m%d")

filename_trunk="${file%.*}"
filename_ext="${file##*.}"
input_movie=$filename_trunk".mov"

if [ -e $vcs_name ]; then
	array_from_file $vcs_name
    ix=$( printf "%s\n" "${my_array[@]}" | grep -n -m 1 "^${filename_trunk}" | cut -d ":" -f1 )
    if [[ -z $ix ]]; then
        previous_version_count=0
    else
        index=$(( ix-1 ))
        newstring="${my_array[$index]}"
        breakstring=(${newstring//=/ })
        previous_version_count="${breakstring[1]}"
    fi
else
	previous_version_count=0
fi

new_version_count=$((previous_version_count+1))

output_filename=$filename_trunk"_"$user_string"."$new_version_count"_"$today".mov"

if [ ! -d $audio_dir ]; then
	mkdir $audio_dir
fi

if [ ! -d $converted_dir ]; then
	mkdir $converted_dir
fi

ffmpeg -i $input_movie -i $file -map 0:v -map 1:a -vcodec libx264 -pix_fmt yuv420p -acodec copy $converted_dir"/"$output_filename

mv $file $audio_dir"/"$filename_trunk"_"$user_string"."$new_version_count"_"$today"."$filename_ext

if [ -e $vcs_name ] && [ $previous_version_count -eq 0 ]
	then
	  echo $filename_trunk"="$new_version_count >> .nuendo_convert_config
elif [ -e $vcs_name ]
	then
	  sed -i '' -e "s/${filename_trunk}.*/${filename_trunk}\=${new_version_count}/g" ${vcs_name}
else
	  echo $filename_trunk"="$new_version_count >> .nuendo_convert_config
fi

echo "Conversion completed for: "$output_filename | mail -s "Nuendo Conversion Complete" $notify_email
