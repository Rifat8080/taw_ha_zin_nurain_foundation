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
    @upcoming_events = Event.upcoming.limit(3)
    @projects = Project.active.limit(6)
    @healthcare_requests = HealthcareRequest.visible_to_public
                                           .includes(:user, :healthcare_donations)
                                           .limit(6)
    @donation = Donation.new
    @submit_text = "Donate Now"

    # Prepare dynamic navigation data
    @navigation_stats = {
      total_active_projects: Project.active.count,
      upcoming_events: Event.upcoming.count,
      healthcare_requests: HealthcareRequest.visible_to_public.count
    }

    render "index"
  end
end