class AddUpdatedByToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :updated_by_id, :uuid
    add_column :events, :updated_by_name, :string
    add_column :events, :updated_by_email, :string
    add_index :events, :updated_by_id
    add_foreign_key :events, :users, column: :updated_by_id
  end
end
