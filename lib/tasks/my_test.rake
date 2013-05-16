namespace :mytests do

  desc "loads data from external site"
  task :env => :environment do
     print "\n" + Rails.env + "\n"
  end
end