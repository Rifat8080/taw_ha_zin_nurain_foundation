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
      render json: { status: "error", message: "Invalid QR code" }, status: :not_found
      return
    end

    if ticket.can_be_used?
      if ticket.use_ticket!
        # Also mark the user as attended in EventUser
        event_user = ticket.user.event_users.find_by(event: ticket.event)
        event_user&.mark_as_attended!

        render json: {
          status: "success",
          message: "Ticket validated successfully",
          ticket: ticket_details_for_response(ticket)
        }
      else
        render json: { status: "error", message: "Failed to validate ticket" }, status: :unprocessable_entity
      end
    else
      case ticket.status
      when "used"
        render json: {
          status: "error",
          message: "Ticket has already been used",
          ticket: ticket_details_for_response(ticket, include_used_at: true)
        }, status: :unprocessable_entity
      when "cancelled"
        render json: {
          status: "error",
          message: "Ticket has been cancelled",
          ticket: ticket_details_for_response(ticket)
        }, status: :unprocessable_entity
      when "refunded"
        render json: {
          status: "error",
          message: "Ticket has been refunded",
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
            message: "Ticket cannot be used yet. Event check-in opens 1 day before the event.",
            ticket: details
          }, status: :unprocessable_entity
        elsif current_date > event_end
          details = ticket_details_for_response(ticket)
          details[:event_end_date] = ticket.event.end_date.strftime("%B %d, %Y")
          render json: {
            status: "error",
            message: "Ticket has expired. Event has ended.",
            ticket: details
          }, status: :unprocessable_entity
        else
          render json: {
            status: "error",
            message: "Ticket cannot be used at this time",
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
