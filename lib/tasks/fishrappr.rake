namespace :fishrappr do
  desc "Reindex issues"
  task reindex_issues: :environment do    
    IssueIndexer.run
  end

  desc "Reindex issues (old)"
  task reindex_issues_old: :environment do    
    Rails.configuration.batch_commit = true
    t0 = Time.now

    total_issues = Issue.count
    Issue.all.each_with_index do |issue, j|
      pages = Page.where(issue_id: issue.id).order(:sequence)
      prev_page = next_page = nil
      pages.each_with_index do |page, i|
        next_page = pages[i+1] || nil
        next_page = next_page.id if next_page
        page.remove_from_index
        page.index_record(prev_page, next_page)
        prev_page = page.id
      end
      Blacklight.default_index.connection.commit
      t1 = Time.now
      STDERR.puts "-- committed: #{j} / #{total_issues} : #{t1 - t0}"
      t0 = t1
    end
  end

  desc "Reindex pages"
  task reindex_pages: :environment do    
    Rails.configuration.batch_commit = true
    t0 = Time.now
    Page.all.each do |page|
      page.remove_from_index
      page.index_record
      if i % 5000 == 0
        Blacklight.default_index.connection.commit
        t1 = Time.now
        STDERR.puts "-- committed: #{i} / #{total_pages} : #{t1 - t0}"
        t0 = t1
      end
    end
    Blacklight.default_index.connection.commit
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
    Blacklight.default_index.connection.commit
  end

end