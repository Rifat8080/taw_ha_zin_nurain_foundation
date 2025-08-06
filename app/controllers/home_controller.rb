class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @upcoming_events = Event.upcoming.limit(3)
    @donation = Donation.new
    @projects = Project.all

    # Add all events for events index display
    @events = Event.includes(:event_users, :tickets).order(:start_date)
  end
end
