class AddProjectIdToQueries < ActiveRecord::Migration[7.0]
  def change
    # We assume at this point only debugging data to be present in DB so it is safe to wipe those tables
    execute 'delete from response_items'
    execute 'delete from queries'

    add_belongs_to :queries, :project, null: false, index: true, foreign_key: true
  end
end
