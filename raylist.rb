#!/usr/bin/ruby

require "fileutils"

class Transcode
  attr_accessor :bitrate
  
  def initialize(bitrate)
    @bitrate = bitrate
	end

  def transcode(song, suffix)
    if @bitrate != 0 then
      puts "Transcoding #{song}"
      lame = IO.popen("lame --abr #{@bitrate} \"#{song}\" \"#{song}#{suffix}\"")
      puts lame.readlines
      puts "Copying id3 tag"
      idcp = IO.popen("id3cp \"#{song}\" \"#{song}#{suffix}\"")
      puts idcp.readlines
    end
  end

end

class CopyMusic
  def put_in_place(song, place, suffix, move)
    directory = "#{place}/#{safe_name(song.artist)}/#{safe_name(song.album)}"
    FileUtils.mkdir_p directory
    
    if move then
      FileUtils.mv("#{song}#{suffix}", "#{directory}/#{format("%02d", song.track)}_#{safe_name(song.title)}.mp3")
    else
      FileUtils.copy_file("#{song}#{suffix}", "#{directory}/#{format("%02d", song.track)}_#{safe_name(song.title)}.mp3")
    end
  end

  private
  def safe_name(filename)
    converted =filename.encode Encoding::UTF_8
    safe = converted.to_s.gsub(/[^a-zA-Z0-9]/, '_')
    if safe.nil?
      return filename
    else
      return safe
    end
  end

end

class SongEntry
  attr_accessor :title, :track, :artist, :album, :path, :bitrate

  def initialize(path)
    @path = path.chomp
    @title = IO.popen("mp3info -p \"%t\" \"#{@path}\"").readlines[0]
    @track = IO.popen("mp3info -p \"%n\" \"#{@path}\"").readlines[0].to_i
    @artist = IO.popen("mp3info -p \"%a\" \"#{@path}\"").readlines[0]
    @album = IO.popen("mp3info -p \"%l\" \"#{@path}\"").readlines[0]
    @bitrate = IO.popen("mp3info -r a -p \"%r\" \"#{@path}\"").readlines[0].to_i		
  end

  def to_s
    "#{@path}"
  end
end

class Playlist

  def each
    @playlist.each{|item| yield item }
  end

  def read(file)
    m3u_fp = File.open(file,'r')
    @playlist = parse(m3u_fp.read)
    m3u_fp.close
    @playlist
  end

  private
  def parse(content)
    m3u_metadata = /\#(.+)$/
    playlist = Array.new
    content.each_line do |line|
      unless m3u_metadata=~line
        playlist << SongEntry.new(line)
      end
    end
    playlist
  end
end



# script:

if ARGV.count() < 2 then
  puts "usage: raylist <m3u_file> <directory_to_deploy> [bitrate]"
  exit(1)
end

m3u_file = ARGV[0].to_s
directory = ARGV[1].to_s
bitrate = 0
if ARGV.count() == 3 then
  bitrate = ARGV[2]
end

playlist = Playlist.new
transcoder = Transcode.new(bitrate)
copier = CopyMusic.new
playlist.read(m3u_file)
suffix = (bitrate != 0 ? ".tmp" : "")
move = (bitrate != 0 ? true : false)
playlist.each { |song|
  puts song
  transcoder.transcode(song, suffix)
  copier.put_in_place(song, directory, suffix, move)
}
puts "\nChicken is ready :)"

