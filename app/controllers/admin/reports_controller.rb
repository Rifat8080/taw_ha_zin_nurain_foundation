class Admin::ReportsController < ApplicationController
  before_action :require_admin

  def index
    # Parse filters
    @start_date = params[:start_date].presence && Date.parse(params[:start_date]) rescue nil
    @end_date = params[:end_date].presence && Date.parse(params[:end_date]) rescue nil
    @project_id = params[:project_id].presence

  donations = Donation.includes(:user, :project).order('donations.created_at DESC')
    expenses = Expense.includes(:project).order(expense_date: :desc)

    if @project_id.present?
      donations = donations.where(project_id: @project_id)
      expenses = expenses.where(project_id: @project_id)
    end

    if @start_date.present?
      donations = donations.where("donations.created_at >= ?", @start_date.beginning_of_day)
      expenses = expenses.where("expense_date >= ?", @start_date)
    end

    if @end_date.present?
      donations = donations.where("donations.created_at <= ?", @end_date.end_of_day)
      expenses = expenses.where("expense_date <= ?", @end_date)
    end

    @donations = donations.page(params[:page]).per(50)
    @expenses = expenses.page(params[:exp_page]).per(50)

    @donations_total = donations.sum(:amount)
    @expenses_total = expenses.sum(:amount)
    @balance = (@donations_total || 0) - (@expenses_total || 0)

    respond_to do |format|
      format.html
      format.csv do
        csv_data = Reports::CsvExporter.generate(donations: donations, expenses: expenses)
        send_data csv_data, filename: "financial_report_#{Time.now.to_date}.csv", type: "text/csv"
      end
    end
  end
end
