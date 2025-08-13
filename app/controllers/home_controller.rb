class HomeController < ApplicationController
  def index
    if user_signed_in?
      # Dashboard view for authenticated users
      render_dashboard
    else
      # Public homepage
      render_public_homepage
    end
  end

  private

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

    # Prepare dynamic navigation data
    @navigation_stats = {
      total_active_projects: Project.active.count,
      upcoming_events: Event.upcoming.count,
      healthcare_requests: HealthcareRequest.visible_to_public.count
    }

    render "index"
  end
end
