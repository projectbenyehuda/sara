require 'sara_utils'
class AddItemDateToResponseItem < ActiveRecord::Migration[7.0]
  def change
    add_column :response_items, :item_date, :string
    add_column :response_items, :normalized_year, :integer

    ResponseItem.destroy_all # remove all previous test data
  end
end
