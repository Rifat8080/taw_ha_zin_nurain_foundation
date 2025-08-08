class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :attendees]
  # before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]
  
  def index
    @events = Event.includes(:event_users, :tickets)
    @events = @events.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?
    @events = @events.by_category(params[:category]) if params[:category].present?
    @events = @events.upcoming if params[:status] == 'upcoming'
    @events = @events.past if params[:status] == 'past'
    @events = @events.active if params[:status] == 'active'
    @events = @events.order(:start_date).page(params[:page])
  end

  def show
    @event_user = current_user&.event_users&.find_by(event: @event)
    @user_tickets = current_user&.tickets&.where(event: @event) || []
  end

  def new
    @event = Event.new
    @event.guests.build # Build an initial guest for the form
  end

  def create
    @event = Event.new(event_params)
    
    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event.guests.build if @event.guests.empty?
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      # Collect all guest errors for better display
      guest_errors = []
      @event.guests.each_with_index do |guest, index|
        if guest.errors.any?
          guest.errors.full_messages.each do |error|
            guest_errors << "Guest #{index + 1}: #{error}"
          end
        end
      end
      
      if guest_errors.any?
        flash.now[:error] = "Please fix the following issues:<br>#{guest_errors.join('<br>')}"
      end
      
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.'
  end
  
  def attendees
    @event_users = @event.event_users.includes(:user).order(:created_at)
    @tickets = @event.tickets.includes(:user).order(:created_at)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :start_date, :end_date, :start_time, :end_time, 
                                  :seat_number, :venue, :guest_list, :guest_description, 
                                  :ticket_price, :ticket_category, :event_image,
                                  guests_attributes: [:id, :name, :title, :description, :image, :_destroy])
  end
end
