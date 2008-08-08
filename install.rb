require 'fileutils'
require 'find'

include FileUtils

RAILS_DIR = File.expand_path('./../../../')
SRC_DIR = File.expand_path('./files/')

files = Array.new

# go through and find each file to install
puts "The following files will be added to your project:\n"
chdir(RAILS_DIR) do 
  Find.find(SRC_DIR) do |path|
    fname = path.sub(SRC_DIR, '')
    puts fname
    files << fname
  end
end

# copy the files all over
files.each do |fname|
  action_needed_confirmation = ''
  if FileTest.exists?(RAILS_DIR + fname)
    puts "#{fname} already exists"
    begin
      puts "Choose the action you want to take:\n"
      puts "use y/Y if you want to overwrite this file \n"
      puts "Use n/N if you do not want to overwrite this file \n"
      puts "Use q/Q to quit the current operation \n"
      action_needed_confirmation = gets.strip.downcase[0..1] rescue nil
    end while !%w[y n q].include?(action_needed_confirmation)
    
    action = action_needed_confirmation
    # depending on the action write or ignore the file
    if action == 'y' || action.empty?
      puts "Copying/overwriting #{fname} over\n"
    elsif action == 'n'
      puts "Ignoring #{fname}\n"
      next
    elsif
      puts "Quitting Current Operation\n"
      exit
    end
  end
  
  # copy the file over since the user didn't quit or ignore
  FileUtils.cp(fname, RAILS_DIR + fname)
  
end

puts "Installation Done!\n"
