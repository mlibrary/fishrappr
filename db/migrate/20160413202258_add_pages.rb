class AddPages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      # t.integer  :page_id  # not needed because active record creates an id column
      t.integer  :issue_id
      t.string   :page_no
      t.string   :page_order
      t.string   :issue_no
      t.string   :text_link
      t.string   :img_link

      t.timestamps null: false
    end

    add_index :pages, :id
  end

  def self.down
    drop_table :pages
  end
end
