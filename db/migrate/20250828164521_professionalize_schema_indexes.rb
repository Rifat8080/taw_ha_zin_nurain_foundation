class ProfessionalizeSchemaIndexes < ActiveRecord::Migration[8.0]
  # Use explicit up/down so we can guard operations by checking index existence
  def up
    # Rename indexes for consistency and clarity (guarded)
    if index_name_exists?(:donations, "index_donations_on_project_created") && !index_name_exists?(:donations, "index_donations_on_project_id_and_created_at")
      rename_index :donations, "index_donations_on_project_created", "index_donations_on_project_id_and_created_at"
    end

    if index_name_exists?(:donations, "index_donations_on_user_created") && !index_name_exists?(:donations, "index_donations_on_user_id_and_created_at")
      rename_index :donations, "index_donations_on_user_created", "index_donations_on_user_id_and_created_at"
    end

    if index_name_exists?(:expenses, "index_expenses_on_project_created") && !index_name_exists?(:expenses, "index_expenses_on_project_id_and_created_at")
      rename_index :expenses, "index_expenses_on_project_created", "index_expenses_on_project_id_and_created_at"
    end

    if index_name_exists?(:healthcare_donations, "index_healthcare_donations_on_user_created") && !index_name_exists?(:healthcare_donations, "index_healthcare_donations_on_user_id_and_created_at")
      rename_index :healthcare_donations, "index_healthcare_donations_on_user_created", "index_healthcare_donations_on_user_id_and_created_at"
    end

    if index_name_exists?(:healthcare_expenses, "index_healthcare_expenses_on_request_created") && !index_name_exists?(:healthcare_expenses, "index_healthcare_expenses_on_request_id_created_at")
      rename_index :healthcare_expenses, "index_healthcare_expenses_on_request_created", "index_healthcare_expenses_on_request_id_created_at"
    end

    # Remove potentially redundant single-column indexes where composite indexes exist
    # Guard by name to avoid PG::UndefinedTable when the expected name is not present
    remove_index :event_users, name: "index_event_users_on_user_id" if index_name_exists?(:event_users, "index_event_users_on_user_id")
    remove_index :tickets, name: "index_tickets_on_user_id" if index_name_exists?(:tickets, "index_tickets_on_user_id")

    # Add missing indexes for frequently queried columns
    add_index :projects, :name, name: "index_projects_on_name" unless index_exists?(:projects, :name)
    add_index :events, :name, name: "index_events_on_name" unless index_exists?(:events, :name)
    add_index :blogs, :published_at, name: "index_blogs_on_published_at" unless index_exists?(:blogs, :published_at)

    # Add composite indexes for common query patterns
    add_index :donations, [ :user_id, :project_id ], name: "index_donations_on_user_project" unless index_exists?(:donations, [ :user_id, :project_id ])
    add_index :healthcare_donations, [ :user_id, :request_id ], name: "index_healthcare_donations_on_user_request" unless index_exists?(:healthcare_donations, [ :user_id, :request_id ])
  end

  def down
    # Reverse added composite indexes
    remove_index :healthcare_donations, name: "index_healthcare_donations_on_user_request" if index_name_exists?(:healthcare_donations, "index_healthcare_donations_on_user_request")
    remove_index :donations, name: "index_donations_on_user_project" if index_name_exists?(:donations, "index_donations_on_user_project")

    # Reverse added single-column indexes
    remove_index :blogs, name: "index_blogs_on_published_at" if index_name_exists?(:blogs, "index_blogs_on_published_at")
    remove_index :events, name: "index_events_on_name" if index_name_exists?(:events, "index_events_on_name")
    remove_index :projects, name: "index_projects_on_name" if index_name_exists?(:projects, "index_projects_on_name")

    # Restore potentially removed single-column indexes
    add_index :tickets, :user_id, name: "index_tickets_on_user_id" unless index_exists?(:tickets, :user_id)
    add_index :event_users, :user_id, name: "index_event_users_on_user_id" unless index_exists?(:event_users, :user_id)

    # Reverse renames (guarded)
    if index_name_exists?(:donations, "index_donations_on_project_id_and_created_at") && !index_name_exists?(:donations, "index_donations_on_project_created")
      rename_index :donations, "index_donations_on_project_id_and_created_at", "index_donations_on_project_created"
    end

    if index_name_exists?(:donations, "index_donations_on_user_id_and_created_at") && !index_name_exists?(:donations, "index_donations_on_user_created")
      rename_index :donations, "index_donations_on_user_id_and_created_at", "index_donations_on_user_created"
    end

    if index_name_exists?(:expenses, "index_expenses_on_project_id_and_created_at") && !index_name_exists?(:expenses, "index_expenses_on_project_created")
      rename_index :expenses, "index_expenses_on_project_id_and_created_at", "index_expenses_on_project_created"
    end

    if index_name_exists?(:healthcare_donations, "index_healthcare_donations_on_user_id_and_created_at") && !index_name_exists?(:healthcare_donations, "index_healthcare_donations_on_user_created")
      rename_index :healthcare_donations, "index_healthcare_donations_on_user_id_and_created_at", "index_healthcare_donations_on_user_created"
    end

    if index_name_exists?(:healthcare_expenses, "index_healthcare_expenses_on_request_id_created_at") && !index_name_exists?(:healthcare_expenses, "index_healthcare_expenses_on_request_created")
      rename_index :healthcare_expenses, "index_healthcare_expenses_on_request_id_created_at", "index_healthcare_expenses_on_request_created"
    end
  end
end
