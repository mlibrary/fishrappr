# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.string  :ht_namespace  #hathitrust namespace
      t.string  :ht_barcode    #hathitrust barcode
      t.string  :volume      #volume number
      t.string  :issue_no    #issue number
      t.string  :edition     #edition number
      t.string  :date_issued #date issued
      t.integer :issue_sequence, default: 1 # track date_issued within barcode      
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
