class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :title
      t.string :slug
      t.string :info_link

      t.timestamps null: false      
    end
    add_index :publications, :slug, unique: true
  end
end
