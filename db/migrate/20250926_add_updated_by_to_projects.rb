class AddUpdatedByToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :updated_by_id, :uuid
    add_column :projects, :updated_by_name, :string
    add_foreign_key :projects, :users, column: :updated_by_id
    add_index :projects, :updated_by_id
  end
end
