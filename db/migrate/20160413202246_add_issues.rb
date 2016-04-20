# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.string  :hathitrust
      t.string  :volume
      t.string  :issue_no
      t.string  :edition
      t.string  :date_issued
      t.string  :newspaper
      t.integer :pages_count # track page associated with this issue

      t.timestamps null: false
    end

    add_index :issues, :id
  end

  def self.down
    drop_table :issues
  end
end
