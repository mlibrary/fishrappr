namespace :fishrappr do
  desc "Reindex pages"
  task reindex_pages: :environment do    
    Page.all.each do |page|
      page.remove_from_index
      page.index_record
      STDERR.puts "#{page.id}"
    end
  end
end