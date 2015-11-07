class CreateTrends < ActiveRecord::Migration
  def change
    create_table :trends do |t|
      t.string :description
      t.text :categories
      t.timestamps null: false
    end
  end
end
