require 'csv'

module Reports
  class CsvExporter
    def self.generate(donations:, expenses:)
      headers = ['type', 'id', 'project_id', 'project_name', 'amount', 'currency', 'date', 'user_id', 'user_email', 'notes']
      CSV.generate(headers: true) do |csv|
        csv << headers

        donations.find_each do |d|
          csv << [
            'donation',
            d.id,
            d.project_id,
            d.project&.name,
            d.amount,
            d.respond_to?(:currency) ? d.currency : 'USD',
            d.created_at.to_s,
            d.user_id,
            d.user&.email,
            d.payment_method || ''
          ]
        end

        expenses.find_each do |e|
          csv << [
            'expense',
            e.id,
            e.project_id,
            e.project&.name,
            e.amount,
            'USD',
            e.expense_date.to_s,
            nil,
            nil,
            e.title
          ]
        end
      end
    end
  end
end
