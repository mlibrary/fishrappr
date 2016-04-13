class AddPages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer  :page_id
      t.integer  :page_no
      t.integer  :page_order
      t.integer  :issue_no
      t.string   :text_link
      t.string   :img_link

      t.timestamps null: false
    end

    add_index :pages, :page_id
  end

  def self.down
    drop_table :pages
  end
end
