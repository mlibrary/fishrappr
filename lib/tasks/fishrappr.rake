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

  desc "Reindex issue"
  # task :reindex_issues, [:volume_identifier] => :environment do |t, args|
  task :reindex_issue => :environment do |t, args|
    if File.exists?(args.extras.first)
      # identifiers = File.readlines(args.extras.first).map{|line| line.chomp}
      identifiers = File.readlines(args.extras.first).each do |line|
        line.chomp!
      end
    else
      identifiers = args.extras
    end
    # if identifiers.empty?
    #   identifiers = Issue.select(:volume_identifier).distinct.collect { |x| x.volume_identifier }.sort
    # end
    total = identifiers.size
    identifiers.each_with_index do |issue_identifier, i|
      STDERR.puts "-- indexing: #{i}/#{total} : #{issue_identifier}"
      is = Issue.where(issue_identifier: issue_identifier).first
      ix = IssueIndexer.new(is)
      ix.index(true)
      # delay = rand() * 1
      # sleep(delay)
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

  desc "Update publication range"
  task :update_publication_range, [ :publication_slug ] => :environment do |t, args|
    publication = Publication.find_by_slug(args[:publication_slug])
    issue = Issue.where('publication_id = ? AND publication_year > 0', publication.id).order(publication_year: :desc).take(1).first
    publication.last_print_year = issue.date_issued.split('-')[0].to_i
    issue = Issue.where('publication_id = ? AND publication_year > 0', publication.id).order(publication_year: :asc).take(1).first
    publication.first_print_year = issue.date_issued.split('-')[0].to_i
    publication.save
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
    args.extras.each do |volume_identifier|
      ingest.fetch_volume volume_identifier
    end
  end

  desc "Import issue"
  task :import_issue, [ :publication_slug, :collid ] => :environment do |t, args|
    ingest = DlxsIngest.new(args[:publication_slug], args[:collid])
    ingest.clobber = true
    STDERR.puts args.extras.first
    if File.exists?(args.extras.first)
      issue_identifiers = File.readlines(args.extras.first).map do |line|
        line.chomp!
        "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/manifest/#{args[:collid]}:#{line}:1"
      end
    else
      issue_identifiers = args.extras.map do |line|
        "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/manifest/#{args[:collid]}:#{line}:1"
      end
    end
    t = issue_identifiers.length
    issue_identifiers.each_with_index do |issue_identifier, i|
      # if ENV['IIIF_MANIFEST']
      #   issue_identifier = "#{ENV['IIIF_MANIFEST']}/#{issue_identifier}"
      # end
      ingest.fetch_issue issue_identifier
      STDERR.puts "-- #{i} / #{t} : #{issue_identifier}"
    end
  end

end
