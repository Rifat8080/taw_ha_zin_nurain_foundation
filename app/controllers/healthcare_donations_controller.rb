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
    # allow admin to search existing users when creating manual donation
    if params[:user_search].present?
      q = "%#{params[:user_search]}%"
      @users = User.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR phone_number ILIKE ?", q, q, q, q).order(:email).limit(500)
    else
      @users = User.order(:email).limit(500)
    end
  end

  # JSON endpoint for searching users (used by live search in manual_new)
  def user_search
    authorize_admin!
    q = params[:q].to_s.strip
    if q.blank?
      render json: { users: [] }
      return
    end

    term = "%#{q}%"
    users = User.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR phone_number ILIKE ?", term, term, term, term).order(:email).limit(50)

    render json: { users: users.map { |u| { id: u.id, full_name: u.full_name, email: u.email, phone_number: u.phone_number } } }
  end

  def manual_create
    authorize_admin!

  # Build donation from params (exclude nested user_attributes when initializing model)
  donation_attrs = manual_donation_params.except(:user_attributes)
  @healthcare_donation = HealthcareDonation.new(donation_attrs)
  @healthcare_donation.manual = true

  # If a user_id was provided, attach that user. If not, attempt to create/find by provided user_attributes
  if manual_donation_params[:user_id].present?
    @healthcare_donation.user_id = manual_donation_params[:user_id]
  elsif params.dig(:healthcare_donation, :user_attributes).present?
    ua = params[:healthcare_donation][:user_attributes].slice(:first_name, :last_name, :email, :phone_number).transform_keys(&:to_s)
    # Try to find existing user by email first
    if ua['email'].present?
      user = User.find_by(email: ua['email'])
    end

    # If not found by email, try phone number
    if user.blank? && ua['phone_number'].present?
      user = User.find_by(phone_number: ua['phone_number'])
    end

    if user.blank? && ua['email'].present?
      # Build minimal attributes for user creation
      user = User.new(first_name: ua['first_name'] || 'Guest', last_name: ua['last_name'] || 'Donor', email: ua['email'], phone_number: ua['phone_number'])
      # mark so validations that depend on full profile can skip
      user.created_by_guest_donation = true
      # set a random password for Devise requirement
      pw = SecureRandom.hex(12)
      user.password = pw
      user.password_confirmation = pw
      user.role = 'member'
      user.address = user.address || 'N/A'
      if user.save
        # optionally send welcome email — intentionally omitted
      else
        @healthcare_requests = HealthcareRequest.accepting_donations
        @users = User.order(:email).limit(500)
        @healthcare_donation.errors.add(:base, 'Could not create user for donation: ' + user.errors.full_messages.join(', '))
        render :manual_new, status: :unprocessable_entity and return
      end
    end

    @healthcare_donation.user = user if user.present?
  end

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
  params.require(:healthcare_donation).permit(:amount, :user_id, :request_id, user_attributes: [:first_name, :last_name, :email, :phone_number])
  end

  def authorize_admin!
    unless current_user&.role == 'admin'
      redirect_to healthcare_donations_path, alert: 'Not authorized.'
    end
  end
end
