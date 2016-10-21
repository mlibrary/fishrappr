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

  desc "New Publication"
  task :new_publication, [ :publication_slug, :publication_title, :publication_href ] => :environment do |t, args|
    publication = Publication.find_or_create_by(slug: args[:publication_slug]) do |publication|
      publication.title = args[:publication_title]
      publication.info_link = args[:publication_href]
    end
    STDERR.puts "-- #{publication.slug}"
  end

  desc "Import volumes"
  task :import_volumes, [ :publication_slug, :collid ] => :environment do |t, args|
    ingest = DlxsIngest.new(args[:publication_slug], args[:collid])
    ingest.fetch_volumes
  end

  desc "Import volume"
  task :import_volume, [ :publication_slug, :collid ] => :environment do |t, args|
    ingest = DlxsIngest.new(args[:publication_slug], args[:collid])
    args.extra.each do |volume_identifier|
      ingest.load volume_identifier
    end
  end

  desc "Import volume (old)"
  task :import_volume_old, [ :publication_slug, :input_filename, :testing ] => :environment do |t, args|
    DailyXmlToDb_v2.new(args[:publication_slug], args[:input_filename], args[:testing]) 
  end

end