class ZakatCalculationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_zakat_calculation, only: [ :show, :edit, :update, :destroy ]

  def index
    @zakat_calculations = current_user.zakat_calculations.includes(:assets, :liabilities).recent
    @current_year = Date.current.year
    @current_calculation = @zakat_calculations.find { |calc| calc.calculation_year == @current_year }
  end

  def show
    @assets_by_category = @zakat_calculation.assets_by_category
    @total_liabilities = @zakat_calculation.liabilities.sum(:amount)
    @nisab_rate = @zakat_calculation.current_nisab_rate
  end

  def new
    @zakat_calculation = current_user.zakat_calculations.build(calculation_year: Date.current.year)

    # Build at least one asset and liability for the form
    @zakat_calculation.assets.build if @zakat_calculation.assets.empty?
    @zakat_calculation.liabilities.build if @zakat_calculation.liabilities.empty?

    # Set current nisab value if available
    current_rate = NisabRate.current_rate
    @zakat_calculation.nisab_value = current_rate&.min_nisab || 0

    @nisab_rate = current_rate
  end

  def create
    @zakat_calculation = current_user.zakat_calculations.build(zakat_calculation_params)

    if @zakat_calculation.save
      @zakat_calculation.update_totals!
      @zakat_calculation.update_nisab_value! if NisabRate.current_rate

      respond_to do |format|
        format.html { redirect_to @zakat_calculation, notice: "Zakat calculation was successfully created." }
        format.turbo_stream { redirect_to @zakat_calculation, notice: "Zakat calculation was successfully created." }
      end
    else
      # Build at least one asset and liability for the form if they're empty
      @zakat_calculation.assets.build if @zakat_calculation.assets.empty?
      @zakat_calculation.liabilities.build if @zakat_calculation.liabilities.empty?
      @nisab_rate = NisabRate.current_rate

      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @zakat_calculation.assets.build if @zakat_calculation.assets.empty?
    @zakat_calculation.liabilities.build if @zakat_calculation.liabilities.empty?
    @nisab_rate = @zakat_calculation.current_nisab_rate
  end

  def update
    if @zakat_calculation.update(zakat_calculation_params)
      @zakat_calculation.update_totals!
      @zakat_calculation.update_nisab_value! if NisabRate.find_by(year: @zakat_calculation.calculation_year)

      respond_to do |format|
        format.html { redirect_to @zakat_calculation, notice: "Zakat calculation was successfully updated." }
        format.turbo_stream { redirect_to @zakat_calculation, notice: "Zakat calculation was successfully updated." }
      end
    else
      # Build at least one asset and liability for the form if they're empty
      @zakat_calculation.assets.build if @zakat_calculation.assets.empty?
      @zakat_calculation.liabilities.build if @zakat_calculation.liabilities.empty?
      @nisab_rate = @zakat_calculation.current_nisab_rate

      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    year = @zakat_calculation.calculation_year
    @zakat_calculation.destroy
    redirect_to zakat_calculations_path, notice: "Zakat calculation for #{year} was successfully deleted."
  end

  # Quick calculation endpoint for AJAX
  def quick_calculate
    total_assets = params[:total_assets].to_f
    total_liabilities = params[:total_liabilities].to_f
    year = params[:year].to_i

    net_assets = total_assets - total_liabilities
    nisab_rate = NisabRate.find_by(year: year) || NisabRate.current_rate
    nisab_value = nisab_rate&.min_nisab || 0

    zakat_due = net_assets >= nisab_value ? (net_assets * 0.025).round(2) : 0

    render json: {
      net_assets: net_assets,
      nisab_value: nisab_value,
      zakat_due: zakat_due,
      zakat_eligible: net_assets >= nisab_value
    }
  end

  private

  def set_zakat_calculation
    @zakat_calculation = current_user.zakat_calculations.find(params[:id])
  end

  def zakat_calculation_params
    params.require(:zakat_calculation).permit(
      :calculation_year, :total_assets, :total_liabilities, :nisab_value,
      assets_attributes: [ :id, :category, :description, :amount, :_destroy ],
      liabilities_attributes: [ :id, :description, :amount, :_destroy ]
    )
  end
end
