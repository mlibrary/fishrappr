class AddPages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      # t.integer  :issue_id  #foreign key to issue table
      t.string   :page_no   #page number; not always found
      t.integer  :issue_sequence  #sequence number to show page order
      t.integer  :volume_sequence  #sequence number to show page order
      t.string   :text_link #link for full text
      t.string   :coordinates_link #link for full text
      t.string   :image_link  #image link
      t.string   :page_identifier

      t.timestamps null: false
      t.belongs_to(:issue, foreign_key: true)

    end

    add_index :pages, :id # using id which is auto generated
  end

  def self.down
    drop_table :pages
  end
end
