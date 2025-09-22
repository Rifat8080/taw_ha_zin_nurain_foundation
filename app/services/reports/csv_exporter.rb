require "csv"

module Reports
  class CsvExporter
    # Accept project donations + healthcare donations and project expenses + healthcare expenses
    def self.generate(donations:, healthcare_donations:, expenses:, healthcare_expenses:)
      headers = [ "type", "id", "project_id", "project_name", "amount", "currency", "date", "user_id", "user_email", "notes" ]
      CSV.generate(headers: true) do |csv|
        csv << headers

        # Regular project donations
        donations.find_each do |d|
          csv << [
            "donation",
            d.id,
            d.project_id,
            d.project&.name,
            d.amount,
            d.respond_to?(:currency) ? d.currency : "USD",
            d.created_at.to_s,
            d.user_id,
            d.user&.email,
            d.payment_method || ""
          ]
        end

        # Healthcare donations: schema does not attach projects to requests, so project fields are nil.
        # Include request id in notes for traceability.
        healthcare_donations.find_each do |d|
          csv << [
            "healthcare_donation",
            d.id,
            nil,
            nil,
            d.amount,
            d.respond_to?(:currency) ? d.currency : "USD",
            d.created_at.to_s,
            d.user_id,
            (d.user&.email || (d.respond_to?(:email) ? d.email : nil)),
            [ "request_id:#{d.request_id}", (d.respond_to?(:payment_method) ? d.payment_method : nil) ].compact.join(" ")
          ]
        end

        # Regular project expenses
        expenses.find_each do |e|
          csv << [
            "expense",
            e.id,
            e.project_id,
            e.project&.name,
            e.amount,
            "USD",
            e.expense_date.to_s,
            nil,
            nil,
            e.title
          ]
        end

        # Healthcare expenses: no project linkage in this schema, include request id in notes
        healthcare_expenses.find_each do |e|
          csv << [
            "healthcare_expense",
            e.id,
            nil,
            nil,
            e.amount,
            "USD",
            e.expense_date.to_s,
            nil,
            nil,
            "request_id:#{e.healthcare_request_id} #{e.description}".strip
          ]
        end
      end
    end
  end
end
