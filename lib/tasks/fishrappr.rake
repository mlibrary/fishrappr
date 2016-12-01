require 'pp'
namespace :fishrappr do
  desc "Reindex issues"
  # task :reindex_issues, [:volume_identifier] => :environment do |t, args|
  task :reindex_issues => :environment do |t, args|
    identifiers = args.extras
    if identifiers.empty?
      identifiers = Issue.select(:volume_identifier).distinct.collect { |x| x.volume_identifier }.sort
    end
    total = identifiers.size
    identifiers.each_with_index do |volume_identifier, i|
      STDERR.puts "-- indexing: #{i}/#{total} : #{volume_identifier}"
      IssueIndexer.run volume_identifier
      # delay = rand() * 1
      # sleep(delay)
    end
  end

  desc "Reindex from"
  task :reindex_issues_from, [ :start ] => :environment do |t, args|
    identifiers = args.extras
    if identifiers.empty?
      identifiers = Issue.select(:volume_identifier).distinct.collect { |x| x.volume_identifier }.sort
    end
    do_skip = true
    total = identifiers.size
    identifiers.each_with_index do |volume_identifier, i|
      if volume_identifier == args[:start]
        do_skip = false
      end
      next if do_skip
      STDERR.puts "-- indexing: #{i}/#{total} : #{volume_identifier}"
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
    ingest.clobber = true
    PP.pp args.extras, STDERR
    args.extras.each do |volume_identifier|
      ingest.fetch_volume volume_identifier
    end
  end

  desc "Import volume (old)"
  task :import_volume_old, [ :publication_slug, :input_filename, :testing ] => :environment do |t, args|
    DailyXmlToDb_v2.new(args[:publication_slug], args[:input_filename], args[:testing])
  end

end
