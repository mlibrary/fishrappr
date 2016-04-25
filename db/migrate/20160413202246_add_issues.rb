# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.string  :hathitrust  #hathitrust id
      t.string  :volume      #volume number
      t.string  :issue_no    #issue number
      t.string  :edition     #edition number
      t.string  :date_issued #date issued
      t.string  :newspaper   #newspaper title
      t.integer :pages_count #track page associated with this issue

      t.timestamps null: false
    end

    add_index :issues, :id
  end

  def self.down
    drop_table :issues
  end
end
