require 'rubygems'
require 'bundler/setup'

Bundler.require
Dotenv.load

filename = ARGV[0]

unless filename
  puts "Specify a filename. Quiting."
  exit
end

start_offset = 0
slice_length = 40

puts "Will attempt to split #{filename} into pieces for analysis..."

filename_no_extension = filename.chomp(File.extname(filename))
Dir.mkdir filename_no_extension + '_slices' unless File.exists?(filename_no_extension + '_slices') 

`sox #{filename} #{filename_no_extension + '_slices/' + filename_no_extension + '.mp3'} trim #{start_offset} #{slice_length} : newfile : restart`

slices = Dir[filename_no_extension + '_slices' + "/*.mp3"]
File.open(filename_no_extension + "_slice_list.txt", "w+") do |f|
  f.puts(slices)
end

echonest_json = `echoprint-codegen -s 0 #{slice_length} < #{filename_no_extension + "_slice_list.txt"}`

File.open(filename_no_extension + "_echoprint_data.json","w+") do |f|
  f.write(JSON.pretty_generate(JSON.parse(echonest_json)))
end

puts "Done."
