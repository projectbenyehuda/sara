class CreateIgnoredItems < ActiveRecord::Migration[7.0]
  def change
    create_table :ignored_items do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :external_id, null: false
      t.integer :source, null: false
      t.timestamp :created_at
    end

    add_index :ignored_items, %i(project_id external_id source), unique: true

    # Also making response_items.external_id column non-nullable because it is required for ignore functionality
    change_column_null :response_items, :external_id, false
  end
end
