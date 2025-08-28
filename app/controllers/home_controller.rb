class HomeController < ApplicationController
  def dashboard
    require_login_and_render_dashboard
  end

  def index
    render_public_homepage
  end

  private

  def require_login_and_render_dashboard
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "You must be signed in to view the dashboard."
      return
    end
    render_dashboard
  end

  def render_dashboard
    @stats = {
      total_projects: Project.count,
      total_donations: Donation.sum(:amount),
      total_volunteers: Volunteer.count,
      total_healthcare_requests: HealthcareRequest.count,
      pending_healthcare_requests: HealthcareRequest.where(status: "pending").count,
      total_events: Event.count,
      upcoming_events: Event.upcoming.count
    }

    @recent_healthcare_requests = HealthcareRequest.includes(:user)
                                                  .order(created_at: :desc)
                                                  .limit(5)

    @recent_donations = if current_user.role == "admin"
                         Donation.includes(:user).order(created_at: :desc).limit(5)
    else
                         current_user.donations.order(created_at: :desc).limit(5)
    end

    @upcoming_events = Event.upcoming.includes(:event_users).limit(3)

    @recent_expenses = if current_user.role == "admin"
                        HealthcareExpense.includes(:user).order(created_at: :desc).limit(5)
    else
                        []
    end

    render "dashboard"
  end

  def render_public_homepage
    # Cache navigation stats for 5 minutes
    @navigation_stats = Rails.cache.fetch("navigation_stats", expires_in: 5.minutes) do
      {
        total_active_projects: Project.where(is_active: true).count,
        upcoming_events: Event.where("start_date >= ?", Date.current).count,
        healthcare_requests: HealthcareRequest.where(approved: true, status: "approved").count
      }
    end

    # Optimize queries with includes and select only needed columns
    @upcoming_events = Event.upcoming
                           .select(:id, :name, :start_date, :guest_description, :total_seats)
                           .includes(:event_users)
                           .limit(6)

    @projects = Project.active
                      .select(:id, :name, :description)
                      .limit(10)

    @healthcare_requests = HealthcareRequest.visible_to_public
                                           .select(:id, :user_id, :patient_name, :reason, :status, :approved, :donations_count, :total_donations_cents)
                                           .includes(:user)
                                           .limit(8)

    @donation = Donation.new
    @submit_text = "Donate Now"
  end
end