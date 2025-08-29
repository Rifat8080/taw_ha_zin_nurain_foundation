class ExpensesController < ApplicationController
  before_action :set_expense, only: [ :show, :edit, :update, :destroy ]

  def index
  # order by the `expense_date` column (column was renamed from `date`)
  @expenses = Expense.includes(:project).all.order(expense_date: :desc)
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
  params.require(:expense).permit(:title, :amount, :expense_date, :project_id)
  end
end
