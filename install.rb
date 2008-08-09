require 'fileutils'
require 'find'

include FileUtils

RAILS_DIR = File.expand_path('./../../../')

puts "Installing the acts_as_calendar plugin\n\n"

# check to see if the calendar directory exists
if !File.exist?(RAILS_DIR + '/app/views/calendar')
  puts "Creating the calendar folder\n"
  FileUtils.mkdir(RAILS_DIR + '/app/views/calendar')
end

# check to see if the form for the calendar exists
if File.exist?(RAILS_DIR + '/app/views/calendar/_form.html.erb')
  action = ''
  begin
    puts "app/views/calendar/_form.html.erb already exists, overwrite it? (y/N)\n"
    # get the action response
    action = gets.strip.downcase[0..1] rescue nil
  end while !%[y n].include?(action)
  
  # decipher the action
  if action == 'y'
    puts "Copying _form.html.erb into app/views/calendar \n"
    FileUtils.cp('./files/app/views/calendar/_form.html.erb', RAILS_DIR + '/app/views/calendar' )
  else
    puts "Skipping _form.html.erb ...\n"
  end
  
else
  puts "Copying _form.html.erb into app/views/calendar \n"
  FileUtils.cp('./files/app/views/calendar/_form.html.erb', RAILS_DIR + '/app/views/calendar' )
end

# check to see if _day_info.html.erb exists or not
if File.exist?(RAILS_DIR + '/app/views/calendar/_day_info.html.erb')
  begin 
    puts "app/views/calendar/_day_info.html.erb already exists, overwrite it? (y/N)\n"
    action = gets.strip.downcase[0..1] rescue nil
  end while !%[y n].include?(action)
  
  if action == 'y'
    puts "Copying _day_info.html.erb into app/views/calendar \n"
    FileUtils.cp('./files/app/views/calendar/_day_info.html.erb', RAILS_DIR + '/app/views/calendar')
  else
    puts "Skipping _day_info.html.erb\n"
  end
  
else
   puts "Copying _day_info.html.erb into app/views/calendar \n"
   FileUtils.cp('./files/app/views/calendar/_day_info.html.erb', RAILS_DIR + '/app/views/calendar')
end

# check to see if the stylesheet is included
if File.exist?(RAILS_DIR + '/public/stylesheets/calendar.css')
  action = ''
  begin
    puts "public/stylesheets/calendar.css already exists, overwrite it? (y/N)\n"
    action = gets.strip.downcase[0..1] rescue nil
  end
  
  if action == 'y'
    puts "Copying calendar.css into public/stylesheets\n"
    FileUtils.cp('./files/public/stylesheets/calendar.css', RAILS_DIR + '/public/stylesheets')
  else
    puts "Skipping calendar.css ... \n"
  end
  
else
  puts "Copying calendar.css into public/stylesheets\n"
  FileUtils.cp('./files/public/stylesheets/calendar.css', RAILS_DIR + '/public/stylesheets')
end

# TODO: create the routes for the calendar
# need to check to see if it exists or not

# this is what i'm using at the moment -asoules
# map.connect ':controller/calendar/:year/:month/:day',
#     :action => 'calendar',
#     :year => nil,
#     :month => nil,
#     :day => nil,
#     :requirements => { :year => /\d{4}/, 
#                        :month => /\d{1,2}/,
#                        :day => /\d{1,2}/ }
                        
# finished copying files over
puts "Installation Complete\n\n"

# display README
puts IO.read(File.join(File.dirname(__FILE__), 'README'))
puts "\n"
