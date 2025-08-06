require 'securerandom'

class DonationsController < ApplicationController
  before_action :set_donation, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :authenticate_user!, only: [:new, :create]

  def index
    @donations = Donation.includes(:user, :project).all
  end

  def show
  end

  def new
    @donation = Donation.new
    @donation.project_id = params[:project_id] if params[:project_id]
    @projects = Project.all
  end

  def create
    @donation = Donation.new(donation_params.except(:first_name, :last_name, :email, :phone_number, :address))
    
    # Handle user assignment
    if current_user
      # User is logged in, assign current user
      @donation.user = current_user
    else
      # User is not logged in, find or create user
      user = find_or_create_donor
      if user.persisted?
        @donation.user = user
      else
        @donation.errors.add(:base, "Unable to create donor: #{user.errors.full_messages.join(', ')}")
        @projects = Project.all
        render :new, status: :unprocessable_entity
        return
      end
    end

    if @donation.save
      if current_user
        redirect_to @donation, notice: "Donation was successfully created."
      else
        redirect_to root_path, notice: "Thank you for your donation! A confirmation will be sent to your email."
      end
    else
      @projects = Project.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @projects = Project.all
  end

  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: "Donation was successfully updated."
    else
      @projects = Project.all
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
    params.require(:donation).permit(:amount, :project_id, :first_name, :last_name, :email, :phone_number, :address)
  end

  def find_or_create_donor
    # Try to find existing user by email or phone number
    existing_user = User.find_by(email: donation_params[:email]) ||
                   User.find_by(phone_number: donation_params[:phone_number])
    return existing_user if existing_user

    # Create new user with a temporary password
    temp_password = SecureRandom.hex(8)
    User.create(
      first_name: donation_params[:first_name],
      last_name: donation_params[:last_name],
      email: donation_params[:email],
      phone_number: donation_params[:phone_number],
      address: donation_params[:address],
      password: temp_password,
      password_confirmation: temp_password,
      role: 'member'
    )
  end
end
