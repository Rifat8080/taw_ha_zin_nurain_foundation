class HealthcareDonationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_healthcare_donation, only: [ :show ]
  before_action :set_healthcare_request, only: [ :new, :create ]

  def index
  # Index should list manual donations only (admin view)
  authorize_admin!
  @requests = HealthcareRequest.all.order(created_at: :desc).limit(200)
  donations = HealthcareDonation.manual.includes(:healthcare_request, :user).recent

  if params[:request_id].present?
    donations = donations.where(request_id: params[:request_id])
  end

  if params[:search].present?
    q = "%#{params[:search]}%"
    # users.full_name is a Ruby method, not a DB column — search first_name/last_name instead
    donations = donations.joins(:user, :healthcare_request).where(
      "users.email ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR healthcare_requests.patient_name ILIKE ? OR healthcare_requests.reason ILIKE ?",
      q, q, q, q, q
    )
  end

  @healthcare_donations = donations.page(params[:page])
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

  # Admin-only manual donation creation for a specified request and donor
  def manual_new
    authorize_admin!
    @healthcare_donation = HealthcareDonation.new
  @healthcare_requests = HealthcareRequest.accepting_donations
    @users = User.order(:email).limit(500)
  end

  def manual_create
    authorize_admin!

  @healthcare_donation = HealthcareDonation.new(manual_donation_params)
  @healthcare_donation.user ||= current_user
  @healthcare_donation.manual = true

    if @healthcare_donation.save
      redirect_to healthcare_donations_path, notice: 'Manual donation created.'
    else
  @healthcare_requests = HealthcareRequest.accepting_donations
      @users = User.order(:email).limit(500)
      render :manual_new, status: :unprocessable_entity
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

  def manual_donation_params
    params.require(:healthcare_donation).permit(:amount, :user_id, :request_id)
  end

  def authorize_admin!
    unless current_user&.role == 'admin'
      redirect_to healthcare_donations_path, alert: 'Not authorized.'
    end
  end
end
