class ExpensesController < ApplicationController
  before_action :set_expense, only: [ :show, :edit, :update, :destroy ]

  def index
    # Preload projects for the filter UI (used by the index view)
    begin
      @projects = Project.active.order(:name)
    rescue => _e
      @projects = Project.order(:name).limit(10) rescue []
    end

    expenses = Expense.includes(:project)

    # Filter by project if provided
    if params[:project_id].present?
      expenses = expenses.where(project_id: params[:project_id])
    end

    # Search across title, project name, notes and amount (text cast)
    if params[:search].present?
      q = "%#{params[:search].to_s.strip}%"
      expenses = expenses.left_joins(:project)
                         .where("expenses.title ILIKE :q OR projects.name ILIKE :q OR CAST(expenses.amount AS TEXT) ILIKE :q OR expenses.notes ILIKE :q", q: q)
    end

    @expenses = expenses.order(expense_date: :desc).page(params[:page])

    # Totals: overall (all expenses), filtered (current result set), and per-project sums
    @overall_expenses_total = Expense.sum(:amount) || 0
    @filtered_expenses_total = expenses.sum(:amount) || 0
    @project_sums = Expense.group(:project_id).sum(:amount)
  end

  def show
  end

  def new
    @expense = Expense.new
    @expense.project_id = params[:project_id] if params[:project_id]
    @projects = Project.all
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      redirect_to @expense, notice: "Expense was successfully created."
    else
      @projects = Project.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @projects = Project.all
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: "Expense was successfully updated."
    else
      @projects = Project.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_url, notice: "Expense was successfully deleted."
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def expense_params
  params.require(:expense).permit(:title, :amount, :expense_date, :project_id, :notes)
  end
end
