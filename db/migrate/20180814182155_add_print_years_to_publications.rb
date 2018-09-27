class AddPrintYearsToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :first_print_year, :integer
    add_column :publications, :last_print_year, :integer
  end
end
