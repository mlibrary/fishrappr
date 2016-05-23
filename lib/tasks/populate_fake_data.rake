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
    Page.destroy_all

    publication = Publication.find_or_create_by(slug: 'the-daily-standup') do |publication|
      publication.title = "The Daily Standup"
      publication.info_link = "https://github.com/mlibrary/fishrappr"
    end

    volume_idx = {}

    Rails.configuration.batch_commit = true
    Rails.configuration.index_enabled = false

    possible_dates = []

    File.open(dates_filename).each do |line|
      line.strip!
      next if line.blank?

      begin
        timestamp = line.to_date
      rescue => e
        STDERR.puts "#{line} : #{e}"
        next
      end
      possible_dates << line
    end

    possible_dates.each_slice(100) do |barcode_dates|

      ht_namespace = "fake"
      # logged for curiosity: sprintf("%014d", rand(1e9..1e10).to_i)
      ht_barcode = (1..14).map{"0123456789".chars.to_a.sample}.join

      ht_path = "#{Rails.configuration.sdrroot}/#{ht_namespace}/#{ht_barcode}"
      if not Dir.exists?(ht_path)
        FileUtils.mkdir_p(ht_path)
      end

      t0 = Time.now

      barcode_dates.each_with_index do |date_issued|

        volume = date_issued.split('-')[1]
        issue_no = volume_idx.fetch(volume, 0) + 1
        volume_idx[volume] = issue_no

        pages_count = rand(25)

        # make an issue
        issue = Issue.create(
          ht_namespace: ht_namespace,
          ht_barcode: ht_barcode,
          publication_id: publication.id,
          volume: volume,
          date_issued: date_issued,
          issue_no: issue_no.to_s,
          pages_count: pages_count,
        )

        (1 .. pages_count ).each do |seq|
          # make a new text file
          text_file_id = "TXT#{'%08d' % seq}"
          image_file_id = "IMAGE#{'%08d' % seq}"


          File.open("#{ht_path}/#{text_file_id}.txt", 'w') do |io|
            io.puts FFaker::CheesyLingo.paragraph
            io.puts FFaker::CheesyLingo.paragraph
          end

          page = Page.create(
            issue_id: issue.id,
            page_no: seq.to_s,
            sequence: seq,
            text_link: text_file_id,
            img_link: image_file_id,
          )

        end

        # Blacklight.default_index.connection.commit
        STDERR.puts "-- #{ht_barcode} : #{date_issued} : #{Time.now - t0}"

      end

    end
  end
# end