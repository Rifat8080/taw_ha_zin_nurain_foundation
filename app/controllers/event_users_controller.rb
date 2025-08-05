class EventUsersController < ApplicationController
  before_action :set_event

  def index
    @event_users = @event.event_users.includes(:user).order(:created_at)
  end

  def create
    @event_user = @event.event_users.build(user: current_user, status: 'registered')
    
    if @event_user.save
      redirect_to @event, notice: 'Successfully registered for the event!'
    else
      redirect_to @event, alert: @event_user.errors.full_messages.join(', ')
    end
  end

  def destroy
    @event_user = @event.event_users.find_by(user: current_user)
    
    if @event_user&.cancel_registration!
      redirect_to @event, notice: 'Registration cancelled successfully.'
    else
      redirect_to @event, alert: 'Unable to cancel registration.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
  
  def current_user
    # This should be implemented based on your authentication system
    # For now, returning nil - you'll need to implement this
    User.first # Temporary implementation
  end
end
