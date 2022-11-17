class AddFavoriteToResponseItems < ActiveRecord::Migration[7.0]
  def change
    add_column :response_items, :favorite, :boolean, null: false, default: false
  end
end
