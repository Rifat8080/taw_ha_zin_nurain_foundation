class HealthcareExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_healthcare_request
  before_action :set_healthcare_expense, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_admin_or_authorized_user, except: [ :index, :show ]

  def index
    @healthcare_expenses = @healthcare_request.healthcare_expenses.recent.includes(:user)
    @total_expenses = @healthcare_request.total_expenses
    @total_donations = @healthcare_request.total_donations
    @balance = @healthcare_request.balance
  end

  def show
  end

  def new
    @healthcare_expense = @healthcare_request.healthcare_expenses.build
  end

  def create
    @healthcare_expense = @healthcare_request.healthcare_expenses.build(healthcare_expense_params)
    @healthcare_expense.user = current_user

    if @healthcare_expense.save
      redirect_to [ @healthcare_request, @healthcare_expense ],
                  notice: "Healthcare expense was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @healthcare_expense.update(healthcare_expense_params)
      redirect_to [ @healthcare_request, @healthcare_expense ],
                  notice: "Healthcare expense was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @healthcare_expense.destroy
    redirect_to healthcare_request_healthcare_expenses_path(@healthcare_request),
                notice: "Healthcare expense was successfully deleted."
  end

  private

  def set_healthcare_request
    @healthcare_request = HealthcareRequest.find(params[:healthcare_request_id])
  end

  def set_healthcare_expense
    @healthcare_expense = @healthcare_request.healthcare_expenses.find(params[:id])
  end

  def healthcare_expense_params
    params.require(:healthcare_expense).permit(:description, :amount, :category, :notes, :receipt_url, :expense_date)
  end

  def ensure_admin_or_authorized_user
    unless current_user.role == "admin" || @healthcare_request.user == current_user
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
