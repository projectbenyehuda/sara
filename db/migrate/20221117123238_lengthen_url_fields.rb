class LengthenUrlFields < ActiveRecord::Migration[7.0]
  def change
    change_column :response_items, :url, :string, null: false, limit: 2048    
    change_column :response_items, :media_url, :string, limit: 2048    
    change_column :response_items, :thumbnail_url, :string, limit: 2048    
  end
end
