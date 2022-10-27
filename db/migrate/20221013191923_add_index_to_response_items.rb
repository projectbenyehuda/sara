class AddIndexToResponseItems < ActiveRecord::Migration[7.0]
  def change
    add_column :response_items, :index, :integer, null: false
  end
end
