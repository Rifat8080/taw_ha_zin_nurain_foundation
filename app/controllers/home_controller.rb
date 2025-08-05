class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @upcoming_events = Event.upcoming.limit(3)
  end
end
