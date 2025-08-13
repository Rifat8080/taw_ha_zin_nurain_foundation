class PublicController < ApplicationController
  def zakat_calculator
    @current_nisab_rate = NisabRate.current_rate
    @nisab_value = @current_nisab_rate&.min_nisab || 0
  end

  def calculate_zakat
    # Simple zakat calculation without requiring authentication
    @assets = params[:assets] || {}
    @liabilities = params[:liabilities] || {}
    @current_nisab_rate = NisabRate.current_rate
    @nisab_value = @current_nisab_rate&.min_nisab || 0

    # Calculate totals
    @total_assets = @assets.values.sum { |amount| amount.to_f }
    @total_liabilities = @liabilities.values.sum { |amount| amount.to_f }
    @net_assets = @total_assets - @total_liabilities

    # Calculate zakat
    @zakat_eligible = @net_assets >= @nisab_value
    @zakat_due = @zakat_eligible ? (@net_assets * 0.025) : 0

    render :zakat_calculator
  end
end
