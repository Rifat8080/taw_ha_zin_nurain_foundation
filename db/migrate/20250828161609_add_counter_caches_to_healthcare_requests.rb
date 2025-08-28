class AddCounterCachesToHealthcareRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :healthcare_requests, :donations_count, :integer, default: 0, null: false
    add_column :healthcare_requests, :total_donations_cents, :integer, default: 0, null: false

    # Add indexes for performance
    add_index :healthcare_requests, :donations_count
    add_index :healthcare_requests, :total_donations_cents

    # Populate counter cache values
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE healthcare_requests
          SET donations_count = COALESCE(donation_counts.count, 0),
              total_donations_cents = COALESCE(donation_totals.total_cents, 0)
          FROM (
            SELECT request_id, COUNT(*) as count
            FROM healthcare_donations
            GROUP BY request_id
          ) donation_counts
          FULL OUTER JOIN (
            SELECT request_id, SUM(amount * 100) as total_cents
            FROM healthcare_donations
            GROUP BY request_id
          ) donation_totals ON donation_counts.request_id = donation_totals.request_id
          WHERE healthcare_requests.id = COALESCE(donation_counts.request_id, donation_totals.request_id)
        SQL
      end
    end
  end
end
