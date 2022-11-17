class MakeResponseItemQueryIdNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :response_items, :query_id, true
  end
end
