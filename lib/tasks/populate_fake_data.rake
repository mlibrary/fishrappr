unless Rails.env.production?
  require 'yaml'

  require 'ffaker'

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

    volume_idx = {}

    Rails.configuration.batch_commit = true
    Rails.configuration.index_enabled = false

    File.open(dates_filename).each do |line|
      line.strip!
      next unless line

      begin
        timestamp = line.to_date
      rescue => e
        STDERR.puts "#{line} : #{e}"
        next
      end

      STDERR.puts line

      t0 = Time.now

      volume = line.split('-')[1]
      issue_no = volume_idx.fetch(volume, 0) + 1
      volume_idx[volume] = issue_no

      pages_count = rand(15)
      hathitrust = "mdp.#{FFaker::IdentificationESCO.drivers_license}"

      # make an issue
      issue = Issue.create(
        hathitrust: hathitrust,
        volume: volume,
        date_issued: line,
        issue_no: issue_no.to_s,
        pages_count: pages_count,
        newspaper: "Michigan Daily",
      )

      (1 .. pages_count ).each do |seq|
        # make a new text file
        text_file_id = "TXT#{'%08d' % seq}"
        image_file_id = "IMAGE#{'%08d' % seq}"

        if not Dir.exists?("./tmp/fake_data/#{hathitrust}")
          Dir.mkdir("./tmp/fake_data/#{hathitrust}")
        end

        File.open("./tmp/fake_data/#{hathitrust}/#{text_file_id}.txt", 'w') do |io|
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

      Blacklight.default_index.connection.commit
      STDERR.puts "-- #{line} : #{Time.now - t0}"

    end
  end
end