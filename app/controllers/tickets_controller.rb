class TicketsController < ApplicationController
  before_action :authenticate_user!, except: [ :qr_scan, :validate_qr ]
  before_action :set_ticket, only: [ :show, :qr_code, :use_ticket, :destroy ]
  before_action :set_event, only: [ :create, :bulk_create ]

  def index
    @tickets = current_user&.tickets&.includes(:event, :user) || []
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.order(created_at: :desc)
  end

  def show
    @qr_data = @ticket.qr_code_data
  end

  def create
    # Check if event has expired
    if @event.event_status == "past"
      redirect_to @event, alert: "Sorry, this event has ended and tickets are no longer available for purchase."
      return
    end

    @ticket = @event.tickets.build
    @ticket.user = current_user
    @ticket.registered_by = current_user

    # Set ticket type from params or default to event's category
    if params[:ticket].present? && params[:ticket][:ticket_type].present?
      @ticket.ticket_type = params[:ticket][:ticket_type]
    else
      @ticket.ticket_type = @event.ticket_category
    end

    # If seat_number is provided in ticket params, use it
    if params[:ticket].present? && params[:ticket][:seat_number].present?
      @ticket.seat_number = params[:ticket][:seat_number]
    end

    # Check if this specific ticket type is available
    if @event.ticket_types.any? && !@event.ticket_type_available?(@ticket.ticket_type)
      redirect_to @event, alert: "Sorry, #{@ticket.ticket_type} tickets are sold out!"
      return
    end

    # Check general availability for legacy events
    if @event.sold_out?
      redirect_to @event, alert: "Sorry, this event is sold out!"
      return
    end

    if @ticket.save
      # Also create an EventUser registration if it doesn't exist
      @event.event_users.find_or_create_by(user: current_user) do |event_user|
        event_user.status = "registered"
      end

      redirect_to ticket_path(@ticket), notice: "Ticket purchased successfully! Your QR code is ready."
    else
      redirect_to @event, alert: @ticket.errors.full_messages.join(", ")
    end
  end

  def bulk_create
    # Check if event has expired
    if @event.event_status == "past"
      redirect_to @event, alert: "Sorry, this event has ended and tickets are no longer available for purchase."
      return
    end

    ticket_quantities = params[:ticket_quantities] || {}

    # Filter out zero quantities
    ticket_quantities = ticket_quantities.select { |type, qty| qty.to_i > 0 }

    if ticket_quantities.empty?
      redirect_to @event, alert: "Please select at least one ticket to purchase."
      return
    end

    created_tickets = []
    errors = []
    total_tickets_requested = ticket_quantities.values.sum(&:to_i)

    # Validate availability for all requested tickets first
    ticket_quantities.each do |ticket_type, quantity|
      quantity = quantity.to_i
      next if quantity <= 0

      # Check availability
      if @event.ticket_types.any?
        unless @event.ticket_type_available?(ticket_type, quantity)
          type_info = @event.get_ticket_type(ticket_type)
          available = @event.available_ticket_types.find { |t| t["category"] == ticket_type }&.dig("seats_remaining") || 0
          errors << "#{type_info&.dig('name') || ticket_type.capitalize} tickets: requested #{quantity}, only #{available} available"
        end
      else
        # Legacy event - check total availability
        if quantity > @event.available_seats
          errors << "Requested #{quantity} tickets, only #{@event.available_seats} available"
        end
      end
    end

    # If there are availability errors, don't proceed
    if errors.any?
      redirect_to @event, alert: "Cannot complete purchase: #{errors.join(', ')}"
      return
    end

    # Create tickets in a transaction
    ActiveRecord::Base.transaction do
      ticket_quantities.each do |ticket_type, quantity|
        quantity = quantity.to_i
        next if quantity <= 0

        quantity.times do |i|
          ticket = @event.tickets.build(
            user: current_user,
            ticket_type: ticket_type,
            registered_by: current_user
          )

          unless ticket.save
            errors << "Failed to create ticket #{i + 1} for #{ticket_type}: #{ticket.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback
          end

          created_tickets << ticket
        end
      end

      # If we got here without errors, all tickets were created successfully
      if errors.empty?
        # Create EventUser registration if it doesn't exist
        @event.event_users.find_or_create_by(user: current_user) do |event_user|
          event_user.status = "registered"
        end

        total_amount = created_tickets.sum(&:price)

        redirect_to @event, notice: "Successfully purchased #{created_tickets.count} ticket(s) for $#{total_amount}! Check your tickets in the 'Your Tickets' section below."
      else
        raise ActiveRecord::Rollback
      end
    end

    # If we reach here, there were errors during ticket creation
    if errors.any?
      redirect_to @event, alert: "Failed to purchase tickets: #{errors.join(', ')}"
    end
  end

  def destroy
    if @ticket.cancel_ticket!
      redirect_to tickets_path, notice: "Ticket cancelled successfully."
    else
      redirect_to @ticket, alert: "Unable to cancel ticket."
    end
  end

  def qr_code
    respond_to do |format|
      format.json { render json: @ticket.qr_code_data }
      format.html
    end
  end

  def use_ticket
    if @ticket.use_ticket!
      # Also mark the user as attended in EventUser
      event_user = @ticket.user.event_users.find_by(event: @ticket.event)
      event_user&.mark_as_attended!

      render json: { status: "success", message: "Ticket used successfully" }
    else
      render json: { status: "error", message: "Unable to use ticket" }, status: :unprocessable_entity
    end
  end

  def qr_scan
    # This will render a page with QR code scanner
  end

  def validate_qr
  qr_code_data = params[:qr_code]
  operation = params[:operation]&.to_s || "entry" # default operation is entry

    if qr_code_data.blank?
      render json: { status: "error", message: "QR code is required" }, status: :bad_request
      return
    end

    # Try to parse JSON data first, fallback to direct QR code
    begin
      parsed_data = JSON.parse(qr_code_data)
      qr_code = parsed_data["qr_code"]
    rescue JSON::ParserError
      qr_code = qr_code_data
    end

  ticket = Ticket.find_by(qr_code: qr_code)

    if ticket.nil?
      render json: {
        status: "error",
        message: "QR code not found. Please verify this is a valid ticket QR code."
      }, status: :not_found
      return
    end

    # Handle different operations
    case operation
    when "entry"
      if ticket.scanned_action?("entry")
        render json: { status: "error", message: "This ticket has already recorded an entry.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        return
      end
      if ticket.can_be_used?
        begin
          ticket.use_ticket!
          event_user = ticket.user.event_users.find_by(event: ticket.event)
          event_user&.mark_as_attended!

          ticket.mark_scanned_action!("entry") rescue nil
          render json: {
            status: "success",
            message: "\u2705 Entry recorded. Welcome!",
            ticket: ticket_details_for_response(ticket)
          }
        rescue ActiveRecord::RecordInvalid => e
          render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      elsif ticket.can_reenter?
        if ticket.scanned_action?("reentry")
          render json: { status: "error", message: "This ticket has already recorded a re-entry.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
          return
        end
        begin
          ticket.reenter!
          ticket.mark_scanned_action!("reentry") rescue nil
          render json: { status: "success", message: "\u{1F501} Re-entry recorded. Welcome back!", ticket: ticket_details_for_response(ticket) }
        rescue ActiveRecord::RecordInvalid => e
          render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      else
        render json: { status: "error", message: "Ticket is not eligible for entry.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
      end

    when "reentry"
      if ticket.scanned_action?("reentry")
        render json: { status: "error", message: "This ticket has already recorded a re-entry.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        return
      end
      if ticket.can_reenter?
        begin
          ticket.reenter!
          ticket.mark_scanned_action!("reentry") rescue nil
          render json: { status: "success", message: "\u{1F501} Re-entry allowed. Have a good time!", ticket: ticket_details_for_response(ticket) }
        rescue ActiveRecord::RecordInvalid => e
          render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      else
        render json: { status: "error", message: "Re-entry not allowed for this ticket.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
      end

    when "meal"
      if ticket.scanned_action?("meal")
        render json: { status: "error", message: "Meal already claimed for this ticket.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        return
      end
      begin
        if ticket.claim_meal!
          ticket.mark_scanned_action!("meal") rescue nil
          render json: { status: "success", message: "\u{1F37D}\uFE0F Meal claimed.", ticket: ticket_details_for_response(ticket) }
        else
          render json: { status: "error", message: "No meals remaining or unable to claim meal.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
      end

    when "start_break"
      if ticket.scanned_action?("start_break")
        render json: { status: "error", message: "Break already started for this ticket.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        return
      end
      begin
        if ticket.start_break!
          ticket.mark_scanned_action!("start_break") rescue nil
          render json: { status: "success", message: "\u{1F515} Break started. Enjoy your break.", ticket: ticket_details_for_response(ticket) }
        else
          render json: { status: "error", message: "Unable to start break.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
      end

    when "end_break"
      if ticket.scanned_action?("end_break")
        render json: { status: "error", message: "Break already ended for this ticket.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        return
      end
      begin
        if ticket.end_break!
          ticket.mark_scanned_action!("end_break") rescue nil
          render json: { status: "success", message: "\u23F1\uFE0F Break ended. Welcome back!", ticket: ticket_details_for_response(ticket) }
        else
          render json: { status: "error", message: "No active break found for this ticket.", ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { status: "error", message: e.record.errors.full_messages.join(", "), ticket: ticket_details_for_response(ticket) }, status: :unprocessable_entity
      end

    when "status_check"
      render json: { status: "success", message: "Ticket status retrieved.", ticket: ticket_details_for_response(ticket) }

    else
      render json: { status: "error", message: "Unknown operation." }, status: :bad_request
    end
  end

  def spot_registration
    # Require volunteer or admin access
    unless current_user&.is_volunteer? || current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied. Volunteer privileges required for spot registration."
      return
    end

    # Get upcoming and active events (not past events)
    @events = Event.where("end_date >= ?", Date.current).order(:start_date)
    @spot_registration = SpotRegistration.new
  end

  def create_spot_registration
    # Require volunteer or admin access
    unless current_user&.is_volunteer? || current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied. Volunteer privileges required for spot registration."
      return
    end

    # Get upcoming and active events (not past events)
    @events = Event.where("end_date >= ?", Date.current).order(:start_date)
    @spot_registration = SpotRegistration.new(spot_registration_params)

    if @spot_registration.valid?
      # Process the spot registration
      result = process_spot_registration(@spot_registration)

      if result[:success]
        redirect_to spot_registration_tickets_path,
                    notice: "Successfully registered #{result[:user].full_name} for #{result[:event].name}. #{result[:tickets_count]} ticket(s) created."
      else
        flash.now[:alert] = result[:error]
        render :spot_registration, status: :unprocessable_entity
      end
    else
      render :spot_registration, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ticket_params
    return {} unless params[:ticket].present?
    params.require(:ticket).permit(:seat_number, :ticket_type)
  end

  def spot_registration_params
    params.require(:spot_registration).permit(:event_id, :first_name, :last_name, :email, :phone_number, :address, :ticket_type, :quantity)
  end

  def process_spot_registration(spot_registration)
    event = Event.find(spot_registration.event_id)

    # Check if event allows registration
    if event.event_status == "past"
      return { success: false, error: "Cannot register for past events." }
    end

    # Check if event has available tickets
    ticket_type = spot_registration.ticket_type
    quantity = spot_registration.quantity.to_i

    if event.ticket_types.any?
      unless event.ticket_type_available?(ticket_type, quantity)
        return { success: false, error: "Not enough #{ticket_type} tickets available." }
      end
    else
      if quantity > event.available_seats
        return { success: false, error: "Not enough tickets available." }
      end
    end

    # Find or create user
    user = User.find_by(email: spot_registration.email) ||
           User.find_by(phone_number: spot_registration.phone_number)

    if user.nil?
      # Create new user with temporary password
      temp_password = SecureRandom.hex(8)
      user = User.new(
        first_name: spot_registration.first_name,
        last_name: spot_registration.last_name,
        email: spot_registration.email,
        phone_number: spot_registration.phone_number,
        address: spot_registration.address || "Walk-in Registration",
        password: temp_password,
        password_confirmation: temp_password,
        role: "member"
      )

      unless user.save
        return { success: false, error: "Failed to create user: #{user.errors.full_messages.join(', ')}" }
      end
    end

    # Create tickets
    created_tickets = []
    quantity.times do
      ticket = event.tickets.build(
        user: user,
        ticket_type: ticket_type,
        registered_by: current_user
      )

      if ticket.save
        created_tickets << ticket
      else
        return { success: false, error: "Failed to create ticket: #{ticket.errors.full_messages.join(', ')}" }
      end
    end

    # Create EventUser registration if it doesn't exist
    event.event_users.find_or_create_by(user: user) do |event_user|
      event_user.status = "registered"
    end

    {
      success: true,
      user: user,
      event: event,
      tickets: created_tickets,
      tickets_count: created_tickets.count
    }
  rescue => e
    { success: false, error: "Registration failed: #{e.message}" }
  end

  def ticket_details_for_response(ticket, include_used_at: false)
    details = {
      id: ticket.id,
      user_name: ticket.user.full_name,
      event_name: ticket.event.name,
      ticket_type: ticket.ticket_type.capitalize,
      seat_number: ticket.seat_number,
      price: "$#{ticket.price}",
      status: ticket.status.capitalize,

      # new state fields for frontend display
      entries_used: ticket.respond_to?(:entries_used) ? ticket.entries_used : nil,
      max_entries: ticket.respond_to?(:max_entries) ? ticket.max_entries : nil,
      entries_left: (ticket.respond_to?(:max_entries) && ticket.respond_to?(:entries_used)) ? [ ticket.max_entries - ticket.entries_used, 0 ].max : nil,

      meals_allowed: ticket.respond_to?(:meals_allowed) ? ticket.meals_allowed : nil,
      meals_claimed: ticket.respond_to?(:meals_claimed) ? ticket.meals_claimed : nil,
      meals_left: (ticket.respond_to?(:meals_allowed) && ticket.respond_to?(:meals_claimed)) ? [ ticket.meals_allowed - ticket.meals_claimed, 0 ].max : nil,

      on_break: ticket.respond_to?(:on_break) ? ticket.on_break : nil,
      last_scanned_at: ticket.respond_to?(:last_scanned_at) && ticket.last_scanned_at ? ticket.last_scanned_at.strftime("%B %d, %Y at %I:%M %p") : nil,
      break_started_at: ticket.respond_to?(:break_started_at) && ticket.break_started_at ? ticket.break_started_at.strftime("%B %d, %Y at %I:%M %p") : nil
    }

    if include_used_at && ticket.status == "used"
      details[:used_at] = ticket.updated_at.strftime("%B %d, %Y at %I:%M %p")
    end

    details
  end
end
