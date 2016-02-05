#!/bin/bash

## title: nuendo conversion for post production workflows
## description: watch a folder for audio output. perform a video layback with the newly created audio. 
## author: dc
## author_email: deesee04@gmail.com
## version: v.001
## date: 20160203

#########
## USER SECTION
## CHANGE THE TWO SETTINGS BELOW

## this can be any unique string. initials work well.
user_string=""

## email address to notify when conversion is completed. 
notify_email=""

## directory in which to place renamed audio, relative to the export directory.
audio_dir="Bounces"

## directory in which to place converted video, relative to the export directory.
converted_dir="Laybacks"

##########
## SCRIPT
## NOT NOT CHANGE BELOW THIS LINE!
## (unless you really want to)

file="$@"
today=$(date +"%Y%m%d")

echo $file

if [ -e ".nuendo_convert_config" ]; then
	previous_version_count=$(cat .nuendo_convert_config)
else
	previous_version_count=0
fi

new_version_count=$((previous_version_count+1))

filename_trunk="${file%.*}"
filename_ext="${file##*.}"
input_movie=$filename_trunk".mov"
output_filename=$filename_trunk"_"$user_string"."$new_version_count"_"$today".mov"

if [ ! -d $audio_dir ]; then
	mkdir "../"$audio_dir
fi

if [ ! -d $converted_dir ]; then
	mkdir "../"$converted_dir
fi

ffmpeg -i $input_movie -i $file -map 0:v -map 1:a -vcodec libx264 -pix_fmt yuv420p -acodec copy "../"$converted_dir"/"$output_filename

mv $file "../"$audio_dir"/"$filename_trunk"_"$user_string"."$new_version_count"_"$today"."$filename_ext

echo $new_version_count > .nuendo_convert_config

echo "Conversion completed for: "$output_filename | mail -s "Nuendo Conversion Complete" $notify_email
