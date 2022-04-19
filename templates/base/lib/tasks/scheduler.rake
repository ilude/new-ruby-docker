# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

require 'rufus-scheduler'
require '/app/config/environment.rb'

desc "run scheduled tasks"
task :scheduler => [ :environment ] do
  scheduler = Rufus::Scheduler.new
  puts "Rufus::Scheduler starting!"

  # see https://github.com/jmettraux/rufus-scheduler
  # for syntax definitions and other documentation

  # scheduler.every '3s' do
  #   puts "This is a test of the emergency broadcasting system. This is only a test!"
  # end

  # scheduler.cron '10 0 * * *', :first => :now do
  #   puts "Starting load requirements" 
  #   puts `nice -n +10 bundle exec ruby script/load_requirements.rb`
  # end

  # scheduler.cron '5 0 * * *', :first => :now do
  #   puts "Starting import_images" 
  #   puts `nice -n +10 bundle exec rake visual:import_images`

  #   puts "Starting load_npi_network_files" 
  #   puts `nice -n +10 bundle exec rake visual:load_npi_network_files`

  #   puts "Starting Profit Report" 
  #   puts `nice -n +10 bundle exec ruby reports/profit_report/profit_report.rb -o /app/public/nightly/profit_report`

  #   puts "Starting Shipping Report" 
  #   puts `nice -n +10 bundle exec ruby reports/profit_report/profit_report.rb -o /app/public/nightly/shipped_report -s open`
  # end

  # scheduler.cron '0 3 * * *', :first => :now do
  #   puts "Starting load Package Sizes" 
  #   puts `nice -n +10 bundle exec rake visual:import_package_sizes`
  # end

  Kernel.trap( "INT" ) do 
    scheduler.shutdown unless scheduler.nil?
  end

  scheduler.join()
end
