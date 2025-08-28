class OptimizeColumnTypes < ActiveRecord::Migration[8.0]
  def change
    # Optimize column types for better performance and storage
    # Change text columns to string for short fields (names, titles, etc.)

    # Projects table - name field (typically short)
    change_column :projects, :name, :string

    # Events table - name field (typically short)
    change_column :events, :name, :string

    # Note: Keep the following as text (longer content):
    # - events.description (can be long)
    # - events.venue (can be long)
    # - events.guest_list (can be long)
    # - events.guest_description (can be long)
    # - projects.description (can be long)
    # - projects.categories (can be long)
    # - blogs.body (long content)
    # - healthcare_requests.reason (can be long)
    # - healthcare_requests.patient_name (can be long but needed for search)

    # Add length validation for string fields to prevent truncation
    # Note: This would be handled in the model validations, not in migration
  end
end
