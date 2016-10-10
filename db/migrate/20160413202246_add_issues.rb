# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.string  :volume_identifier  #hathitrust namespace
      t.integer :publication_year
      t.string  :publication_title
      t.string  :volume      #volume number
      t.string  :issue_no    #issue number
      t.string  :edition     #edition number
      t.string  :date_issued #date issued
      t.integer :variant, default: 1 # track date_issued within barcode      
      t.integer :pages_count #track page associated with this issue

      t.timestamps null: false
      t.belongs_to(:publication, foreign_key: true)
    end

    add_index :issues, :id
    add_index :issues, :publication_id
  end

  def self.down
    drop_table :issues
  end
end
