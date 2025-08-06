class TicketsController < ApplicationController
  before_action :authenticate_user!, except: [ :qr_scan, :validate_qr ]
  before_action :set_ticket, only: [ :show, :qr_code, :use_ticket, :destroy ]
  before_action :set_event, only: [ :create ]

  def index
    @tickets = current_user&.tickets&.includes(:event, :user) || []
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.order(created_at: :desc)
  end

  def show
    @qr_data = @ticket.qr_code_data
  end

  def create
    @ticket = @event.tickets.build
    @ticket.user = current_user
    @ticket.ticket_type = @event.ticket_category

    # If seat_number is provided in ticket params, use it
    if params[:ticket].present? && params[:ticket][:seat_number].present?
      @ticket.seat_number = params[:ticket][:seat_number]
    end

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

    if ticket.can_be_used?
      if ticket.use_ticket!
        # Also mark the user as attended in EventUser
        event_user = ticket.user.event_users.find_by(event: ticket.event)
        event_user&.mark_as_attended!

        render json: {
          status: "success",
          message: "✅ Welcome! Ticket validated successfully. Enjoy the event!",
          ticket: ticket_details_for_response(ticket)
        }
      else
        render json: { 
          status: "error", 
          message: "Unable to validate ticket due to a system error. Please try again or contact support." 
        }, status: :unprocessable_entity
      end
    else
      case ticket.status
      when "used"
        used_date = ticket.updated_at.strftime("%B %d, %Y at %I:%M %p")
        render json: {
          status: "error",
          message: "⚠️ This ticket was already used on #{used_date}. Each ticket can only be used once.",
          ticket: ticket_details_for_response(ticket, include_used_at: true)
        }, status: :unprocessable_entity
      when "cancelled"
        render json: {
          status: "error",
          message: "❌ This ticket has been cancelled and cannot be used. Please contact support if you believe this is an error.",
          ticket: ticket_details_for_response(ticket)
        }, status: :unprocessable_entity
      when "refunded"
        render json: {
          status: "error",
          message: "💰 This ticket has been refunded and is no longer valid. Please purchase a new ticket if you wish to attend.",
          ticket: ticket_details_for_response(ticket)
        }, status: :unprocessable_entity
      else
        # Check specific reasons why ticket can't be used
        current_date = Date.current
        event_start = ticket.event.start_date
        event_end = ticket.event.end_date

        if current_date < event_start.advance(days: -1)
          details = ticket_details_for_response(ticket)
          details[:event_start_date] = ticket.event.start_date.strftime("%B %d, %Y")
          render json: {
            status: "error",
            message: "⏰ Check-in is not available yet. Entry opens 1 day before the event on #{details[:event_start_date]}.",
            ticket: details
          }, status: :unprocessable_entity
        elsif current_date > event_end
          details = ticket_details_for_response(ticket)
          details[:event_end_date] = ticket.event.end_date.strftime("%B %d, %Y")
          render json: {
            status: "error",
            message: "⌛ This ticket has expired. The event ended on #{details[:event_end_date]}.",
            ticket: details
          }, status: :unprocessable_entity
        else
          render json: {
            status: "error",
            message: "⚠️ This ticket cannot be used at this time. Please contact support for assistance.",
            ticket: ticket_details_for_response(ticket)
          }, status: :unprocessable_entity
        end
      end
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
    params.require(:ticket).permit(:seat_number)
  end

  def ticket_details_for_response(ticket, include_used_at: false)
    details = {
      id: ticket.id,
      user_name: ticket.user.full_name,
      event_name: ticket.event.name,
      ticket_type: ticket.ticket_type.capitalize,
      seat_number: ticket.seat_number,
      price: "$#{ticket.price}",
      status: ticket.status.capitalize
    }

    if include_used_at && ticket.status == "used"
      details[:used_at] = ticket.updated_at.strftime("%B %d, %Y at %I:%M %p")
    end

    details
  end
end
