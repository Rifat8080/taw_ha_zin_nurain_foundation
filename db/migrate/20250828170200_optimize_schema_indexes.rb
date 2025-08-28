class OptimizeSchemaIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add missing strategic indexes
    add_index :blogs, [:published_at, :created_at], name: "index_blogs_on_published_and_created_at"
    add_index :donations, :amount, name: "index_donations_on_amount"
    add_index :events, :created_at, name: "index_events_on_created_at"
    add_index :expenses, :amount, name: "index_expenses_on_amount"
    add_index :guests, :created_at, name: "index_guests_on_created_at"
    add_index :healthcare_requests, [:status, :created_at], name: "index_healthcare_requests_on_status_created_at"
    add_index :payments, :created_at, name: "index_payments_on_created_at"
    add_index :projects, :created_at, name: "index_projects_on_created_at"
    add_index :users, :created_at, name: "index_users_on_created_at"
    add_index :volunteers, :created_at, name: "index_volunteers_on_created_at"
    add_index :zakat_calculations, :created_at, name: "index_zakat_calculations_on_created_at"

    # Add covering indexes for common queries
    add_index :healthcare_donations, [:request_id, :user_id, :created_at], name: "index_healthcare_donations_covering"
    add_index :tickets, [:user_id, :status, :created_at], name: "index_tickets_user_status_created_at"

    # Add partial indexes for active records
    add_index :blogs, :created_at, name: "index_published_blogs_on_created_at", where: "published_at IS NOT NULL"
    add_index :projects, :created_at, name: "index_active_projects_on_created_at", where: "project_status_active = true"
  end
end
