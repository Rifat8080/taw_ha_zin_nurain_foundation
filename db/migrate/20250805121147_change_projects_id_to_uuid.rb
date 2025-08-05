class ChangeProjectsIdToUuid < ActiveRecord::Migration[8.0]
  def up
    # Create a new table with UUID primary key
    create_table :projects_new, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :name
      t.text :categories
      t.text :description
      t.boolean :project_status_active
      t.timestamps
    end

    # Copy data from old table to new table (if any exists)
    execute <<-SQL
      INSERT INTO projects_new (name, categories, description, project_status_active, created_at, updated_at)
      SELECT name, categories, description, project_status_active, created_at, updated_at
      FROM projects;
    SQL

    # Drop the old table
    drop_table :projects

    # Rename the new table to the original name
    rename_table :projects_new, :projects
  end

  def down
    # Create the old table structure with integer ID
    create_table :projects_old do |t|
      t.text :name
      t.text :categories
      t.text :description
      t.boolean :project_status_active
      t.timestamps
    end

    # Copy data back (UUIDs will be lost, new integer IDs assigned)
    execute <<-SQL
      INSERT INTO projects_old (name, categories, description, project_status_active, created_at, updated_at)
      SELECT name, categories, description, project_status_active, created_at, updated_at
      FROM projects;
    SQL

    # Drop the UUID table
    drop_table :projects

    # Rename back to original name
    rename_table :projects_old, :projects
  end
end
