class MakeExternalIdLonger < ActiveRecord::Migration[7.0]
  def change
    change_column :response_items, :external_id, :string, limit: 2048
  end
end
