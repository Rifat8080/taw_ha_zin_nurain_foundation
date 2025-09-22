class Admin::ReportsController < ApplicationController
  before_action :require_admin

  def index
    # Parse filters
    @start_date = params[:start_date].presence && Date.parse(params[:start_date]) rescue nil
    @end_date = params[:end_date].presence && Date.parse(params[:end_date]) rescue nil
    # Combined entity filter: either "project:ID" or "request:ID"
    @selected_entity = params[:entity].presence
    @project_id = params[:project_id].presence
    @request_id = nil
    if @selected_entity&.start_with?("project:")
      @project_id = @selected_entity.split(":", 2)[1]
    elsif @selected_entity&.start_with?("request:")
      @request_id = @selected_entity.split(":", 2)[1]
    end

  # Project donations (regular) and healthcare donations
  donations = Donation.includes(:user, :project).order("donations.created_at DESC")
  healthcare_donations = HealthcareDonation.includes(:user, :healthcare_request).order("healthcare_donations.created_at DESC")

  # Project expenses and healthcare expenses
  expenses = Expense.includes(:project).order(expense_date: :desc)
  healthcare_expenses = HealthcareExpense.includes(:healthcare_request).order(expense_date: :desc)

    if @project_id.present?
      donations = donations.where(project_id: @project_id)
      expenses = expenses.where(project_id: @project_id)
      # When filtering by a project we do not want to show healthcare records
      # (healthcare_requests are not tied to projects in this schema), so
      # explicitly hide healthcare donations and expenses.
      healthcare_donations = HealthcareDonation.none
      begin
        healthcare_expenses = HealthcareExpense.none
      rescue => _e
        healthcare_expenses = HealthcareExpense.none
      end
    end

    # If a healthcare request was selected, filter healthcare sets to that request
    if @request_id.present?
      healthcare_donations = healthcare_donations.where(request_id: @request_id)
      begin
        healthcare_expenses = healthcare_expenses.where(healthcare_request_id: @request_id)
      rescue => _e
        # Some schema variants may use different column names; ignore if absent
      end

      # When a healthcare request is selected we intentionally hide project donations/expenses
      donations = Donation.none
      expenses = Expense.none
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

    # Chart data: time series over the selected period (default last 30 days)
    chart_start = @start_date || (Date.today - 29)
    chart_end = @end_date || Date.today
    labels = (chart_start..chart_end).map { |d| d.strftime("%Y-%m-%d") }

    donations_by_date = (donations.to_a + healthcare_donations.to_a).group_by { |d| d.created_at.to_date }
    expenses_by_date = (expenses.to_a + healthcare_expenses.to_a).group_by { |e| (e.respond_to?(:expense_date) ? e.expense_date : e.created_at.to_date) }

    @chart_labels = labels
    @donation_series = labels.map { |lbl| (donations_by_date[Date.parse(lbl)] || []).sum { |r| r.amount.to_f } }
    @expense_series = labels.map { |lbl| (expenses_by_date[Date.parse(lbl)] || []).sum { |r| r.amount.to_f } }

    # Donation source breakdown
    project_don_total = donations.sum(:amount) || 0
    healthcare_don_total = healthcare_donations.sum(:amount) || 0
    @donation_source_breakdown = { project: project_don_total.to_f, healthcare: healthcare_don_total.to_f }

    respond_to do |format|
      format.html
      format.csv do
  csv_data = Reports::CsvExporter.generate(donations: donations, healthcare_donations: healthcare_donations, expenses: expenses, healthcare_expenses: healthcare_expenses)
        send_data csv_data, filename: "financial_report_#{Time.now.to_date}.csv", type: "text/csv"
      end
    end
  end
end
