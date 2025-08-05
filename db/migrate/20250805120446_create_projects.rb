class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.text :name
      t.text :categories
      t.text :description
      t.boolean :project_status_active

      t.timestamps
    end
  end
end
