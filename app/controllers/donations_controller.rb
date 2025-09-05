require "securerandom"

class DonationsController < ApplicationController
  before_action :set_donation, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def index
    # Preload projects for the filter UI (used by the index view)
    begin
      @projects = Project.active.order(:name)
    rescue => _e
      @projects = Project.order(:name).limit(10) rescue []
    end

    donations = Donation.includes(:user, :project)

    # Filter by project if provided
    if params[:project_id].present?
      donations = donations.where(project_id: params[:project_id])
    end

    # Search across donor name/email, project name, and amount (text cast)
    if params[:search].present?
      q = "%#{params[:search].to_s.strip}%"
      donations = donations.left_joins(:user, :project)
                           .where("users.first_name ILIKE :q OR users.last_name ILIKE :q OR users.email ILIKE :q OR projects.name ILIKE :q OR CAST(donations.amount AS TEXT) ILIKE :q", q: q)
    end

    @donations = donations.order(created_at: :desc).page(params[:page])
  # Totals: overall (all donations), filtered (current result set), and per-project sums
  @overall_donations_total = Donation.sum(:amount) || 0
  @filtered_donations_total = donations.sum(:amount) || 0
  # per-project totals (hash: project_id => sum)
  @project_sums = Donation.group(:project_id).sum(:amount)
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
      nil
    end
  end

  def create
    # We accept primary_amount (for the current show page project) and extras_json (array of {project_id, amount})
    primary_amount = params.dig(:donation, :primary_amount)
    extras_json = params.dig(:donation, :extras_json)

    main_attrs = donation_params.except(:email).to_h
    # Remove temporary keys we use only for the request payload so they aren't mass-assigned
    main_attrs.delete('primary_amount') if main_attrs.key?('primary_amount')
    main_attrs.delete('extras_json') if main_attrs.key?('extras_json')
    # If primary_amount provided, use it as the main donation amount; otherwise fall back to donation[:amount]
    if primary_amount.present?
      main_attrs['amount'] = BigDecimal(primary_amount.to_s)
    end

    @donation = Donation.new(main_attrs)

    if current_user
      @donation.user = current_user
    else
      email = params.dig(:donation, :email)
      unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
        @donation.errors.add(:email, "is invalid or missing for a guest donation")
        prepare_homepage_data
        render "home/index", status: :unprocessable_entity
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
        render "home/index", status: :unprocessable_entity
        return
      end
    end

    saved = false
    extras_created = []
    Donation.transaction do
      saved = @donation.save
      # create extras if provided
      if saved && extras_json.present?
        begin
          extras = JSON.parse(extras_json) rescue []
          extras.each do |ex|
            next unless ex['amount'].present? && ex['project_id'].present?
            d = Donation.new(amount: ex['amount'], project_id: ex['project_id'])
            d.user = @donation.user
            if d.save
              extras_created << d
            else
              Rails.logger.warn("Failed to save extra donation for project #{ex['project_id']}: #{d.errors.full_messages.join(', ')}")
            end
          end
        rescue => e
          Rails.logger.warn("Failed to create extra donations: #{e.message}")
        end
      end
    end

    if saved
      # Notify admins about new donation and the donor themselves
      begin
        admins = User.where(role: "admin")
        admins.find_each do |admin|
          NotificationService.notify(
            recipient: admin,
            actor: @donation.user,
            notifiable: @donation,
            action: "donation_created",
            title: "New donation received",
            body: "#{@donation.user.full_name} donated $#{@donation.amount} to #{@donation.project&.name || 'the foundation'}"
          )
        end
      rescue => e
        Rails.logger.error("Notification error (donation): ")
        Rails.logger.error(e.message)
      end

      # Notify donor (useful for guest donations that create user)
      begin
        NotificationService.notify(
          recipient: @donation.user,
          actor: @donation.user,
          notifiable: @donation,
          action: "donation_received",
          title: "Thank you for your donation",
          body: "We received your donation of $#{@donation.amount}."
        )
      rescue => e
        Rails.logger.error("Notification error (donor): #{e.message}")
      end

      # Notify for any extras created via Add to Giving (admins + donor per extra)
      if extras_created.any?
        begin
          admins = User.where(role: "admin")
          extras_created.each do |extra_d|
            admins.find_each do |admin|
              NotificationService.notify(
                recipient: admin,
                actor: extra_d.user,
                notifiable: extra_d,
                action: "donation_created",
                title: "New donation received",
                body: "#{extra_d.user.full_name} donated $#{extra_d.amount} to #{extra_d.project&.name || 'the foundation'}"
              )
            end
          end
        rescue => e
          Rails.logger.error("Notification error (extras admin): #{e.message}")
        end

        begin
          extras_created.each do |extra_d|
            NotificationService.notify(
              recipient: extra_d.user,
              actor: extra_d.user,
              notifiable: extra_d,
              action: "donation_received",
              title: "Thank you for your donation",
              body: "We received your donation of $#{extra_d.amount} to #{extra_d.project&.name || 'the foundation'}."
            )
          end
        rescue => e
          Rails.logger.error("Notification error (extras donor): #{e.message}")
        end
      end

      if current_user && !@donation.user.created_by_guest_donation
        redirect_to @donation, notice: "Donation was successfully created."
      else
        user = @donation.user
        sign_in(user)
        redirect_to edit_user_registration_path, notice: "Thank you for your donation! Please set up a secure password for your account."
      end
    else
      prepare_homepage_data
      render "home/index", status: :unprocessable_entity
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
    params.require(:donation).permit(:amount, :project_id, :email, :primary_amount, :extras_json)
  end

  def find_or_create_donor(email)
    existing_user = User.find_by(email: email)
    return existing_user if existing_user

    temp_password = SecureRandom.hex(8)
    first_name = email.split("@").first.humanize

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
