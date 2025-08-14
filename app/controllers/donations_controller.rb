require "securerandom"

class DonationsController < ApplicationController
  before_action :set_donation, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def index
    @donations = Donation.includes(:user, :project).all
  end

  def show
  end

  def new
    @donation = Donation.new
    
    if params[:project_id].present?
      project = Project.find_by(id: params[:project_id])
      if project && project.active?
        @donation.project_id = params[:project_id]
      elsif project
        redirect_to projects_path, alert: "This project is not currently accepting donations."
        return
      else
        redirect_to projects_path, alert: "Project not found."
        return
      end
    end
    
    @projects = Project.active.order(:name)
    
    if @projects.empty?
      redirect_to projects_path, alert: "No projects are currently accepting donations."
      return
    end
  end

  def create
    @donation = Donation.new(donation_params.except(:email))

    if current_user
      @donation.user = current_user
    else
      email = params.dig(:donation, :email)
      unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
        @donation.errors.add(:email, "is invalid or missing for a guest donation")
        prepare_homepage_data
        render 'home/index', status: :unprocessable_entity
        return
      end

      result = find_or_create_donor(email)
      user = result.is_a?(Array) ? result[0] : result
      temp_password = result.is_a?(Array) ? result[1] : nil

      if user.persisted?
        @donation.user = user
        if temp_password.present?
          UserMailer.welcome_donor(user, temp_password).deliver_now
        end
      else
        @donation.errors.add(:base, "Unable to create donor account: #{user.errors.full_messages.join(', ')}")
        prepare_homepage_data
        render 'home/index', status: :unprocessable_entity
        return
      end
    end

    if @donation.save
      if current_user && !@donation.user.created_by_guest_donation
        redirect_to @donation, notice: "Donation was successfully created."
      else
        user = @donation.user
        sign_in(user)
        redirect_to edit_user_registration_path, notice: "Thank you for your donation! Please set up a secure password for your account."
      end
    else
      prepare_homepage_data
      render 'home/index', status: :unprocessable_entity
    end
  end

  def edit
    @projects = Project.active.order(:name)
  end

  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: "Donation was successfully updated."
    else
      @projects = Project.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @donation.destroy
    redirect_to donations_url, notice: "Donation was successfully deleted."
  end

  private

  def set_donation
    @donation = Donation.find(params[:id])
  end

  def donation_params
    params.require(:donation).permit(:amount, :project_id, :email)
  end

  def find_or_create_donor(email)
    existing_user = User.find_by(email: email)
    return existing_user if existing_user

    temp_password = SecureRandom.hex(8)
    first_name = email.split('@').first.humanize
    
    user = User.new(
      first_name: first_name,
      last_name: "User",
      email: email,
      phone_number: "donor-#{Time.now.to_i}-#{rand(1000)}",
      address: "Not provided",
      password: temp_password,
      password_confirmation: temp_password,
      role: "member"
    )
    user.created_by_guest_donation = true
    user.save

    [ user, temp_password ]
  end

  def prepare_homepage_data
    @upcoming_events = Event.upcoming.limit(3)
    @projects = Project.active.limit(6)
    @healthcare_requests = HealthcareRequest.visible_to_public.includes(:user, :healthcare_donations).limit(6)
    @submit_text = "Donate Now"
    @donation ||= Donation.new(donation_params.except(:email))
  end
end