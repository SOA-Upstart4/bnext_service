class CreateTrends < ActiveRecord::Migration
  def change
    create_table :trends do |t|
      t.string :description
      t.string :links # link of the feed itself
      t.string :titles
      t.string :categories
      t.string :authors
      t.string :dates # edited date of the feeed
      t.text :contents
      t.string :tags
      t.string :imgs

      t.timestamps null: false
    end
  end
end
