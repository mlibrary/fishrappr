require 'pp'
namespace :fishrappr do
  desc "Reindex issues"
  # task :reindex_issues, [:volume_identifier] => :environment do |t, args|
  task :reindex_issues => :environment do |t, args|
    args.extras.each do |volume_identifier|
      STDERR.puts "-- indexing: #{volume_identifier}"
      IssueIndexer.run volume_identifier
    end
  end

  desc "Import volume"
  task :import_volume, [ :publication_slug, :input_filename, :testing ] => :environment do |t, args|
    PP.pp args, STDERR
    DailyXmlToDb_v2.new(args[:publication_slug], args[:input_filename], args[:testing]) 
  end

end