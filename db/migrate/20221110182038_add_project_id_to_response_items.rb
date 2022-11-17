class AddProjectIdToResponseItems < ActiveRecord::Migration[7.0]
  def change
    add_belongs_to :response_items, :project, index: true, foreign_key: true
    execute 'update response_items ri set project_id = (select project_id from queries q where q.id = ri.query_id)'
    change_column_null :response_items, :project_id, false
  end
end
