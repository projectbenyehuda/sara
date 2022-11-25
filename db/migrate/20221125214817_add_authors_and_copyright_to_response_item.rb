class AddAuthorsAndCopyrightToResponseItem < ActiveRecord::Migration[7.0]
  def change
    add_column :response_items, :authors, :string, limit: 300
    add_column :response_items, :copyright, :integer
  end
end
