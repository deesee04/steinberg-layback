### steinberg-layback
automatically process laybacks from steinberg products such as cubase and nuendo.

- daw: nuendo
- platform: osx
- requirements: xmllint, ffmpeg

note: ffmpeg must include the libx264 codec (sorta. you can change the codec (and options) if you want. 

#### dependencies:

install xmllint via the libxml2 package via homebrew:
```sh
    $ brew update
    $ brew install libxml2
```

download/clone the repository.

- place the nuendo-convert.sh script in a directory of your choosing (such as ~/My Documents).
- place the nuendo-convert.aepp file in the /Library/Application Support/Steinberg/Audio Export Post Process Scripts/ folder.
- place the nuendo-convert.png file in the /Library/Application Support/Steinberg/Audio Export Post Process Scripts/ folder.

###quick setup:

  - place the source video file in a directory of your choosing (e.g. ~/My Documents/Sessions/ProjectName/Source/Video). 
  - rename the video file according to the base naming convention you wish to use for this project (e.g. Client_Project_VideoVersionNumber.mov).

edit the text between the PATH tags in nuendo-convert.aepp to reflect the path to the nuendo-convert.sh script.

edit the config settings at the top of nuendo-convert.sh:
  
   - ```user_string``` : a unique identifier. useful for tracking the last known owner. any string will do, but choosing something meaningful is a good idea. initials always work. 
   - ```notify_email``` : the email address to notify when the process has completed. 
   - ```audio_dir``` : the final directory in which you wish to place your bounced audio. once the process has completed, the audio exported from the session will be renamed to reflect the same convention as the converted video.  
   - ```converted_dir``` : the final directory in which you wish to place your layback. 
   - ```r_folder_depth``` : the amount of folders we should back up before creating the two defined above. setting this to 0 will create the two folders above in the same folder as your movie clip. 
   - ```vcs_name``` : the name of the configuration file. there's no reason to change this... unless you are incredibly picky. like me. 

###usage:

  choose a cycle region and select 'audio mixdown'. name the export with the same name as your movie clip and place it in the same directory. 
  
  for example, if the movie clip is found at: ```/Users/myuser/Desktop/Project/mymovie_01_cut2.mov```, export the mixdown to: ```/Users/myuser/Desktop/project/mymovie_01_cut2.wav```
  
  in the 'audio mixdown' window, under 'post process', select 'layback to video and rename/version".
 
  


