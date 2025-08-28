class CleanUpDuplicateIndexes < ActiveRecord::Migration[8.0]
  def change
    # Remove redundant single-column indexes that are covered by composite indexes

    # Donations table - remove redundant indexes
    remove_index :donations, :project_id, name: "index_donations_on_project_id" if index_exists?(:donations, :project_id, name: "index_donations_on_project_id")
    remove_index :donations, :user_id, name: "index_donations_on_user_id" if index_exists?(:donations, :user_id, name: "index_donations_on_user_id")

    # Events table - remove duplicate GIN indexes
    remove_index :events, :ticket_types_config, name: "index_events_on_ticket_types_config" if index_exists?(:events, :ticket_types_config, name: "index_events_on_ticket_types_config")
    remove_index :events, :ticket_types_config, name: "index_events_on_ticket_types_config_gin" if index_exists?(:events, :ticket_types_config, name: "index_events_on_ticket_types_config_gin")
    # Keep only: index_events_ticket_types_gin

    # Expenses table - remove redundant index
    remove_index :expenses, :project_id, name: "index_expenses_on_project_id" if index_exists?(:expenses, :project_id, name: "index_expenses_on_project_id")

    # Healthcare Donations table - remove redundant indexes
    remove_index :healthcare_donations, :request_id, name: "index_healthcare_donations_on_request_id" if index_exists?(:healthcare_donations, :request_id, name: "index_healthcare_donations_on_request_id")
    remove_index :healthcare_donations, :user_id, name: "index_healthcare_donations_on_user_id" if index_exists?(:healthcare_donations, :user_id, name: "index_healthcare_donations_on_user_id")

    # Healthcare Expenses table - remove redundant index
    remove_index :healthcare_expenses, :healthcare_request_id, name: "index_healthcare_expenses_on_healthcare_request_id" if index_exists?(:healthcare_expenses, :healthcare_request_id, name: "index_healthcare_expenses_on_healthcare_request_id")

    # Healthcare Requests table - remove redundant indexes
    remove_index :healthcare_requests, :approved, name: "index_healthcare_requests_on_approved" if index_exists?(:healthcare_requests, :approved, name: "index_healthcare_requests_on_approved")
    remove_index :healthcare_requests, :status, name: "index_healthcare_requests_on_status" if index_exists?(:healthcare_requests, :status, name: "index_healthcare_requests_on_status")
    remove_index :healthcare_requests, [ :status, :approved ], name: "index_healthcare_requests_on_status_approved" if index_exists?(:healthcare_requests, [ :status, :approved ], name: "index_healthcare_requests_on_status_approved")

    # Payments table - remove redundant index
    remove_index :payments, :project_id, name: "index_payments_on_project_id" if index_exists?(:payments, :project_id, name: "index_payments_on_project_id")

    # Tickets table - remove duplicate GIN index
    remove_index :tickets, :scan_actions, name: "index_tickets_on_scan_actions" if index_exists?(:tickets, :scan_actions, name: "index_tickets_on_scan_actions")
    # Keep only: index_tickets_scan_actions_gin

    # Rename indexes for consistency
    rename_index :events, "index_events_ticket_types_gin", "index_events_on_ticket_types_config" if index_exists?(:events, :ticket_types_config, name: "index_events_ticket_types_gin")
    rename_index :tickets, "index_tickets_scan_actions_gin", "index_tickets_on_scan_actions" if index_exists?(:tickets, :scan_actions, name: "index_tickets_scan_actions_gin")
  end
end
