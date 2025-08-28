class ImproveColumnNamingAndDefaults < ActiveRecord::Migration[8.0]
  def change
    # Rename columns for better clarity
    rename_column :expenses, :date, :expense_date
    rename_column :events, :seat_number, :total_seats
    rename_column :projects, :project_status_active, :is_active

    # Add better default values
    change_column_default :projects, :is_active, false
    change_column_default :blogs, :published_at, nil

    # Optimize text vs string usage
    change_column :blogs, :body, :text # Keep as text for long content
    change_column :events, :description, :text # Keep as text for long content
    change_column :projects, :description, :text # Keep as text for long content
    change_column :volunteers_teams, :name, :string, limit: 100
    change_column :volunteers_teams, :district, :string, limit: 50
    change_column :work_orders, :title, :string, limit: 200
    change_column :work_orders, :description, :text # Keep as text
    change_column :work_orders, :checklist, :text # Keep as text
  end
end
