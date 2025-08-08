class HealthcareDonationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_healthcare_donation, only: [ :show ]
  before_action :set_healthcare_request, only: [ :new, :create ]

  def index
    @healthcare_donations = current_user.healthcare_donations
                                       .includes(:healthcare_request)
                                       .recent
                                       .page(params[:page])
  end

  def show
  end

  def new
    unless @healthcare_request.can_receive_donations?
      redirect_to @healthcare_request, alert: "This request is not accepting donations at the moment."
      return
    end

    @healthcare_donation = HealthcareDonation.new
  end

  def create
    unless @healthcare_request.can_receive_donations?
      redirect_to @healthcare_request, alert: "This request is not accepting donations at the moment."
      return
    end

    @healthcare_donation = current_user.healthcare_donations.build(healthcare_donation_params)
    @healthcare_donation.healthcare_request = @healthcare_request

    if @healthcare_donation.save
      redirect_to @healthcare_request, notice: "Thank you for your donation!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_healthcare_donation
    @healthcare_donation = HealthcareDonation.find(params[:id])
  end

  def set_healthcare_request
    @healthcare_request = HealthcareRequest.find(params[:healthcare_request_id]) if params[:healthcare_request_id]
  end

  def healthcare_donation_params
    params.require(:healthcare_donation).permit(:amount)
  end
end
