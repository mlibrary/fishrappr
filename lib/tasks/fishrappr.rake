namespace :fishrappr do
  desc "Reindex pages"
  task reindex_pages: :environment do    
    Page.all.each do |page|
      page.remove_from_index
      page.index_record
      STDERR.puts "#{page.id}"
    end
  end

  desc "Index pages (does not remove)"
  task index_pages: :environment do
    Rails.configuration.batch_commit = true
    t0 = Time.now
    total_pages = Page.count
    Page.all.each_with_index do |page, i|
      page.index_record
      if i % 5000 == 0
        Blacklight.default_index.connection.commit
        t1 = Time.now
        STDERR.puts "-- committed: #{i} / #{total_pages} : #{t1 - t0}"
        t0 = t1
      end
    end
  end

end