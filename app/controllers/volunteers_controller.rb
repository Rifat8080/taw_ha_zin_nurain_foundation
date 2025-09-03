class VolunteersController < ApplicationController
  before_action :set_volunteer, only: [ :show, :edit, :update, :destroy ]

  def index
    # start with volunteers and include related teams; use left_joins so we can search on user columns
    @volunteers = Volunteer.left_joins(:user).includes(:volunteers_teams)

    # Role filter (dropdown)
    @volunteers = @volunteers.by_role(params[:role]) if params[:role].present?

    # Free-text search across user name, email and phone
    if params[:search].present?
      q = "%#{params[:search].to_s.strip}%"
      @volunteers = @volunteers.where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR users.phone_number ILIKE ?", q, q, q, q)
    end

    @volunteers = @volunteers.distinct
  end

  def show
    @team_assignments = @volunteer.team_assignments.includes(:volunteers_team)
  end

  def new
    @volunteer = Volunteer.new
    @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil })
  end

  def create
    # Handle inline user creation if user params were provided
    user = find_or_build_inline_user

    @volunteer = Volunteer.new(volunteer_params)
    # If the inline email corresponds to an existing user who is already a volunteer,
    # reject early with a clear error message.
    if user.present? && user.persisted? && user.is_volunteer?
      @volunteer.errors.add(:base, "Selected user is already registered as a volunteer")
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil })
      render :new and return
    end

    @volunteer.user = user if user.present?

    # If the inline-created or existing user already has a volunteer record created
    # by a callback, avoid creating a duplicate volunteer and redirect to the existing one.
    if user.present? && user.persisted? && user.volunteer.present?
      redirect_to user.volunteer, notice: "Volunteer already exists for selected user" and return
    end

    if @volunteer.save
      redirect_to @volunteer, notice: "Volunteer was successfully created."
    else
      # Merge user errors into volunteer.errors so they show up in the form
      if user && user.errors.any?
        user.errors.full_messages.each { |m| @volunteer.errors.add(:base, "User: #{m}") }
      end
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil })
      render :new
    end
  end

  def edit
    @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil }).or(User.where(id: @volunteer.user_id))
  end

  def update
    # If inline user params sent, create/find user and associate
    user = find_or_build_inline_user
    # If inline user exists and is already a volunteer (and not the current volunteer), fail with an error
    if user.present? && user.persisted? && user.is_volunteer? && user.volunteer != @volunteer
      @volunteer.errors.add(:base, "Selected user is already registered as a volunteer")
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil }).or(User.where(id: @volunteer.user_id))
      render :edit and return
    end

    @volunteer.user = user if user.present?

    if @volunteer.update(volunteer_params)
      redirect_to @volunteer, notice: "Volunteer was successfully updated."
    else
      if user && user.errors.any?
        user.errors.full_messages.each { |m| @volunteer.errors.add(:base, "User: #{m}") }
      end
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil }).or(User.where(id: @volunteer.user_id))
      render :edit
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: "Volunteer was successfully deleted."
  end

  # JSON endpoint used by live-search in the volunteer form
  # GET /volunteers/user_search.json?q=term
  def user_search
    q = params[:q].to_s.strip
    users = User.none
    if q.present?
      pattern = "%#{q}%"
      # Only return users who do not already have a volunteer record
      users = User.left_joins(:volunteer)
                  .where(volunteers: { id: nil })
                  .where("first_name ILIKE :p OR last_name ILIKE :p OR email ILIKE :p OR phone_number ILIKE :p", p: pattern)
                  .limit(20)
    end

    render json: users.select(:id, :first_name, :last_name, :email, :phone_number).map { |u| { id: u.id, name: [ u.first_name, u.last_name ].compact.join(" "), email: u.email, phone: u.phone_number } }
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:volunteer).permit(:user_id, :joining_date, :role)
  end

  # Build or find a User from inline form params (params[:user]).
  # Returns a persisted or non-persisted User instance or nil if no inline user params provided.
  def find_or_build_inline_user
    return nil unless params[:user].present?

    user_attrs = params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :address)
    # If email present, try to find existing user by email
    if user_attrs[:email].present?
      existing = User.find_by(email: user_attrs[:email])
      return existing if existing.present?
    end

  # Build new user and set role to volunteer
  user = User.new(user_attrs)
  user.role = "volunteer"
  # Ensure validations that depend on guest flag are satisfied
  user.created_by_guest_donation = false
  # Devise requires a password - generate a random one for inline-created users
  generated_password = SecureRandom.hex(12)
  user.password = generated_password
  user.password_confirmation = generated_password
  user.save
  user
  end
end
