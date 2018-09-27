class SeedPublicationPrintYears < ActiveRecord::Migration[5.2]
  def change
  	Publication.all.each do |pub|
  		pub.first_print_year = Issue.where("publication_id=? AND publication_year > ?", pub.id, 1000).minimum('publication_year')
  		pub.last_print_year = Issue.where("publication_id=? AND publication_year > ?", pub.id, 1000).maximum('publication_year')
  		pub.save
  	end
  end
end
