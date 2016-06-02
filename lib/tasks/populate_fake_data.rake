# unless Rails.env.production?
require 'yaml'

require 'ffaker'
require 'fileutils'

namespace :fishrappr do

  desc "Populate database with much fake data."
  task :populate_fake_data, [:dates_filename] => :environment do |t, args|
    ENV["RAILS_ENV"] ||= "development"

    fake_setup(args[:dates_filename])

    puts "Done."
  end

  task :verify_dates, [:dates_filename] => :environment do |t, args|
    File.open(args[:dates_filename]).each do |line|
      line.strip!
      begin
        timestamp = line.to_date
      rescue => e
        STDERR.puts "#{line} : #{e}"
      end
    end
  end

end

def fake_setup(dates_filename)
  Issue.where(ht_namespace: 'fake').destroy_all

  publication = Publication.find_or_create_by(slug: 'the-daily-standup') do |publication|
    publication.title = "The Daily Standup"
    publication.info_link = "https://github.com/mlibrary/fishrappr"
  end

  volume_idx = {}

  Rails.configuration.batch_commit = true
  Rails.configuration.index_enabled = false

  possible_issues = []

  File.open(dates_filename).each do |line|
    line.strip!
    next unless line.index("\t")

    barcode, date_range = line.split("\t")
    barcode_path = "#{Rails.configuration.sdrdataroot}/fake/#{barcode}"
    next unless Dir.exists?(barcode_path)

    date_range, postscript = date_range.split(" / ")

    date_from, date_to = date_range.split(' - ')
    date_from = Time.strptime(date_from, "%Y %b %d")
    date_to = Time.strptime(date_to, "%Y %b %d")
    delta = date_to - date_from
    delta = delta / 60 / 60 / 24

    puts "== #{barcode}"
    filenames = Dir.glob("#{barcode_path}/TXT*.txt").collect do |filename|
      File.basename(filename, ".txt")
    end
    filenames.sort!

    filenames.shift
    filenames.shift
    filenames.shift
    filenames.pop
    filenames.pop   # some shifting to deal with binding

    possible_date_issues = []
    date_issue = date_from
    while date_issue <= date_to
      # puts date_issue.strftime("%Y-%m-%d")
      check_mm_dd = date_issue.strftime("%m-%d")
      check_day = date_issue.strftime("%a")
      skip = false
      skip |= ( check_mm_dd >= '12-24' and check_mm_dd <= '12-31' )
      skip |= ( check_mm_dd >= '01-01' and check_mm_dd <= '01-06' )
      skip |= ( check_day == 'Sun' || check_day == 'Sat' )
      possible_date_issues << date_issue unless skip
      STDERR.puts "SKIPPING #{date_issue.strftime("%Y-%m-%d")}" if skip
      date_issue += ( 1 * 24 * 60 * 60 )
    end
    
    num_pages = (filenames.size / possible_date_issues.size).floor
    puts "#{filenames.size} : #{num_pages}"

    # now build issues
    possible_date_issues.each do |date_issued|
      volume = date_issued.strftime("%Y")
      issue_no = volume_idx.fetch(volume, 0) + 1
      volume_idx[volume] = issue_no
      issue_data = {
        ht_namespace: 'fake',
        ht_barcode: barcode,
        date_issued: date_issued.strftime("%Y-%m-%d"),
        pages: filenames.shift(num_pages),
        volume: volume,
        issue_no: issue_no,
      }
      possible_issues << issue_data
    end
  end

  possible_issues.each do |issue_data|

    t0 = Time.now

    # PP.pp issue_data, STDERR

    # make an issue
    issue = Issue.create(
      ht_namespace: issue_data[:ht_namespace],
      ht_barcode: issue_data[:ht_barcode],
      publication_id: publication.id,
      volume: issue_data[:volume],
      date_issued: issue_data[:date_issued],
      issue_no: issue_data[:issue_no].to_s,
      pages_count: issue_data[:pages].size,
    )

    issue_data[:pages].each_with_index do |text_file_id, seq|
      page = Page.create(
        issue_id: issue.id,
        page_no: seq.to_s,
        sequence: seq,
        text_link: text_file_id
      )
    end

    STDERR.puts "-- #{issue.ht_barcode} : #{issue.date_issued} : #{Time.now - t0}"

  end

end
