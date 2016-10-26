# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.string  :volume_identifier  #hathitrust namespace
      t.string  :issue_identifier
      t.integer :publication_year
      t.string  :publication_title
      t.string  :volume      #volume number
      t.string  :issue_number    #issue number
      t.string  :edition     #edition number
      t.string  :date_issued #date issued
      t.integer :variant_sequence, default: 1 # track date_issued within barcode      
      t.integer :pages_count #track page associated with this issue

      t.timestamps null: false
      t.belongs_to(:publication, foreign_key: true)
    end

    add_index :issues, :id
    add_index :issues, :publication_id
    add_index :issues, :issue_identifier
    add_index :issues, :volume_identifier
  end

  def self.down
    drop_table :issues
  end
end
