class AddExternalIdToResponseItems < ActiveRecord::Migration[7.0]
  def change
    add_column :response_items, :external_id, :string
  end
end
