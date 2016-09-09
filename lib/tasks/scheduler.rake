desc "This task is called by the Heroku scheduler add-on"
task :remove_stale_offerings => :environment do
  puts "Removing stale offerings..."
  Offering.remove_stale
  puts "done."
end