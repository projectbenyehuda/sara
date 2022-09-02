class CreateResponseItems < ActiveRecord::Migration[7.0]
  def change
    create_table :response_items do |t|
      t.belongs_to :query, index: true, foreign_key: true
      t.integer :source, null: false
      t.integer :media_type, null: false
      t.string :url, null: false
      t.string :title
      t.text :text
      t.timestamps
    end
  end
end
