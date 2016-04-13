# issues 
class AddIssues < ActiveRecord::Migration
  def self.up      
    create_table :issues do |t|
      t.integer :issue_id
      t.string  :hathitrust
      t.integer :volume
      t.integer :issue_no
      t.integer :edition
      t.string :dateIssued
      t.string :newspaper

      t.timestamps null: false
    end

    add_index :issues, :issue_id
  end

  def self.down
    drop_table :issues
  end
end
