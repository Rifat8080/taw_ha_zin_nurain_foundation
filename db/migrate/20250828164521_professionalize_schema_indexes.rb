class ProfessionalizeSchemaIndexes < ActiveRecord::Migration[8.0]
  def change
    # Rename indexes for consistency and clarity
    rename_index :donations, "index_donations_on_project_created", "index_donations_on_project_id_and_created_at"
    rename_index :donations, "index_donations_on_user_created", "index_donations_on_user_id_and_created_at"
    rename_index :expenses, "index_expenses_on_project_created", "index_expenses_on_project_id_and_created_at"
    rename_index :healthcare_donations, "index_healthcare_donations_on_user_created", "index_healthcare_donations_on_user_id_and_created_at"
    rename_index :healthcare_expenses, "index_healthcare_expenses_on_request_created", "index_healthcare_expenses_on_request_id_created_at"

    # Remove potentially redundant single-column indexes where composite indexes exist
    # These single-column indexes may not be needed if composite indexes cover the same columns
    remove_index :event_users, name: "index_event_users_on_user_id" if index_exists?(:event_users, :user_id)
    remove_index :tickets, name: "index_tickets_on_user_id" if index_exists?(:tickets, :user_id)

    # Add missing indexes for frequently queried columns
    add_index :projects, :name, name: "index_projects_on_name" unless index_exists?(:projects, :name)
    add_index :events, :name, name: "index_events_on_name" unless index_exists?(:events, :name)
    add_index :blogs, :published_at, name: "index_blogs_on_published_at" unless index_exists?(:blogs, :published_at)

    # Add composite indexes for common query patterns
    add_index :donations, [ :user_id, :project_id ], name: "index_donations_on_user_project" unless index_exists?(:donations, [ :user_id, :project_id ])
    add_index :healthcare_donations, [ :user_id, :request_id ], name: "index_healthcare_donations_on_user_request" unless index_exists?(:healthcare_donations, [ :user_id, :request_id ])

    # Optimize existing indexes by removing unused ones
    # Note: Keep single-column indexes only if they're used for queries that don't benefit from composite indexes
    # The following indexes are kept as they serve specific query patterns:
    # - index_users_on_email (unique constraint)
    # - index_users_on_role (frequent filtering)
    # - index_projects_on_active_and_created_at (composite for active projects)
  end
end
