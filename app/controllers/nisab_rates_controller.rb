class NisabRatesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_nisab_rate, only: [ :show, :edit, :update, :destroy ]

  def index
    @nisab_rates = NisabRate.recent.page(params[:page]).per(10)
    @current_rate = NisabRate.current_rate
  end

  def show
  end

  def new
    @nisab_rate = NisabRate.new(year: Date.current.year)
  end

  def create
    @nisab_rate = NisabRate.new(nisab_rate_params)

    if @nisab_rate.save
      redirect_to @nisab_rate, notice: "Nisab rate was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @nisab_rate.update(nisab_rate_params)
      redirect_to @nisab_rate, notice: "Nisab rate was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    year = @nisab_rate.year
    @nisab_rate.destroy
    redirect_to nisab_rates_path, notice: "Nisab rate for #{year} was successfully deleted."
  end

  private

  def set_nisab_rate
    @nisab_rate = NisabRate.find(params[:id])
  end

  def nisab_rate_params
    params.require(:nisab_rate).permit(:year, :gold_price_per_gram, :silver_price_per_gram)
  end

  def ensure_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
