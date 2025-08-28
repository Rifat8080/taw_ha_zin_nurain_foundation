class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Composite indexes for common queries
    add_index :healthcare_requests, [:approved, :status], name: "index_healthcare_requests_on_approved_and_status" unless index_exists?(:healthcare_requests, [:approved, :status])
    add_index :events, [:start_date, :end_date], name: "index_events_on_date_range" unless index_exists?(:events, [:start_date, :end_date])
    add_index :projects, [:project_status_active, :created_at], name: "index_projects_on_active_and_created_at" unless index_exists?(:projects, [:project_status_active, :created_at])
    add_index :donations, [:project_id, :created_at], name: "index_donations_on_project_and_date" unless index_exists?(:donations, [:project_id, :created_at])

    # Partial indexes for better performance (using static condition)
    add_index :healthcare_requests, :created_at, where: "approved = true AND status = 'approved'", name: "index_approved_healthcare_requests_on_created_at" unless index_exists?(:healthcare_requests, :created_at, name: "index_approved_healthcare_requests_on_created_at")
    # Note: Skipping partial index on events start_date due to CURRENT_DATE immutability requirement

    # Foreign key indexes (if not already present)
    add_index :healthcare_donations, [:request_id, :created_at], name: "index_healthcare_donations_on_request_and_date" unless index_exists?(:healthcare_donations, [:request_id, :created_at])
    add_index :healthcare_expenses, [:healthcare_request_id, :created_at], name: "index_healthcare_expenses_on_request_and_date" unless index_exists?(:healthcare_expenses, [:healthcare_request_id, :created_at])
  end
end
