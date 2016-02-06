# steinberg-layback
automatically process laybacks from steinberg products such as cubase and nuendo.

daw: nuendo
platform: osx
requirements: fswatch, ffmpeg*

*ffmpeg must include the libx264 codec**
**sorta. you can change the codec (and options) if you want. though, as of this commit.. why would you? 

installation:

install fswatch via homebrew:

  $ brew update
  $ brew install fswatch

download/clone the script and place it in a directory of your choosing (such as ~/My Documents):

  http://link/to/script

quick setup:

  place the source video file in a directory of your choosing (e.g. ~/My Documents/Sessions/ProjectName/Source/Video). rename the video file according to the base naming convention you wish to use for this project (e.g. Client_Project_VideoVersionNumber.mov).

  edit the config settings:

    a. user_string : a unique identifier. useful for tracking the last known owner. any string will do, but choosing something meaningful is a good idea. initials always work. 
    b. notify_email : the email address to notify when the process has completed. 
    c. audio_dir : the final directory in which you wish to place your bounced audio. once the process has completed, the audio exported from the session will be renamed to reflect the same convention as the converted video.  
    d. converted_dir : the final directory in which you wish to place your layback. 
    e. vcs_name : the name of the configuration file. there's no reason to change this... unless you are incredibly picky. like me. 

  configure fswatch:

    $ fswatch -d0v -e ".*" -i ".wav" /path/to/project/exports | xargs -0 -n1 /path/to/script/nuendo-convert.sh
