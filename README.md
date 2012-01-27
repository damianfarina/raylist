# Raylist

Simple Ruby script that helps me to move my music collection to a flash device the way my car's stereo likes.
It reads a m3u file and copies each track in order to the destination directory, probably a mounted flash card or so.
It can re-encode each track too

## Usage
`raylist.rb <m3u_file> <directory_to_deploy> [bitrate]`

## Requirements
* ruby (http://www.ruby-lang.org)
* mp3info (http://ibiblio.org/mp3info)
* lame (http://lame.sourceforge.net)
* id3lib (http://id3lib.sourceforge.net)

