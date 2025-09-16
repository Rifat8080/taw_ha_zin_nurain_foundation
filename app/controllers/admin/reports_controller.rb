class Admin::ReportsController < ApplicationController
  before_action :require_admin

  def index
    # Parse filters
    @start_date = params[:start_date].presence && Date.parse(params[:start_date]) rescue nil
    @end_date = params[:end_date].presence && Date.parse(params[:end_date]) rescue nil
    @project_id = params[:project_id].presence

  # Project donations (regular) and healthcare donations
  donations = Donation.includes(:user, :project).order("donations.created_at DESC")
  healthcare_donations = HealthcareDonation.includes(:user, :healthcare_request).order("healthcare_donations.created_at DESC")

  # Project expenses and healthcare expenses
  expenses = Expense.includes(:project).order(expense_date: :desc)
  healthcare_expenses = HealthcareExpense.includes(:healthcare_request).order(expense_date: :desc)

    if @project_id.present?
      donations = donations.where(project_id: @project_id)
      expenses = expenses.where(project_id: @project_id)

  # Note: `healthcare_requests` do not reference projects in this schema,
  # so we cannot reliably filter healthcare_donations/expenses by project here.
  # Keep the healthcare sets unfiltered when a project_id is provided.
    end

    if @start_date.present?
      donations = donations.where("donations.created_at >= ?", @start_date.beginning_of_day)
      healthcare_donations = healthcare_donations.where("healthcare_donations.created_at >= ?", @start_date.beginning_of_day)
      expenses = expenses.where("expense_date >= ?", @start_date)
      healthcare_expenses = healthcare_expenses.where("expense_date >= ?", @start_date)
    end

    if @end_date.present?
      donations = donations.where("donations.created_at <= ?", @end_date.end_of_day)
      healthcare_donations = healthcare_donations.where("healthcare_donations.created_at <= ?", @end_date.end_of_day)
      expenses = expenses.where("expense_date <= ?", @end_date)
      healthcare_expenses = healthcare_expenses.where("expense_date <= ?", @end_date)
    end

  # Combine and paginate using Kaminari for in-memory arrays
  combined_donations = (donations.to_a + healthcare_donations.to_a).sort_by { |d| d.created_at }.reverse
  @donations = Kaminari.paginate_array(combined_donations).page(params[:page]).per(50)

  combined_expenses = (expenses.to_a + healthcare_expenses.to_a).sort_by { |e| e.respond_to?(:expense_date) ? e.expense_date : e.created_at }.reverse
  @expenses = Kaminari.paginate_array(combined_expenses).page(params[:exp_page]).per(50)

  # Totals
  @donations_total = (donations.sum(:amount) || 0) + (healthcare_donations.sum(:amount) || 0)
  @expenses_total = (expenses.sum(:amount) || 0) + (healthcare_expenses.sum(:amount) || 0)
  @balance = @donations_total - @expenses_total

    respond_to do |format|
      format.html
      format.csv do
  csv_data = Reports::CsvExporter.generate(donations: donations, healthcare_donations: healthcare_donations, expenses: expenses, healthcare_expenses: healthcare_expenses)
        send_data csv_data, filename: "financial_report_#{Time.now.to_date}.csv", type: "text/csv"
      end
    end
  end
end
