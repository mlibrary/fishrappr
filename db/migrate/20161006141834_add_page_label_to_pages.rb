class AddPageLabelToPages < ActiveRecord::Migration
  def change
    add_column :pages, :page_label, :string
    add_index :pages, :page_label
  end
end
