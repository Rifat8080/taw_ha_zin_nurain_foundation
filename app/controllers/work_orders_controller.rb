class WorkOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_work_order, only: [ :show, :edit, :update, :destroy ]

  def index
    @work_orders = WorkOrder.includes(:volunteers_team, :assigned_by_user).all
    @work_orders = @work_orders.by_team(params[:team_id]) if params[:team_id].present?
    @work_orders = @work_orders.assigned_by(params[:assigned_by]) if params[:assigned_by].present?

    case params[:status]
    when "upcoming"
      @work_orders = @work_orders.upcoming
    when "past"
      @work_orders = @work_orders.past
    end

    @work_orders = @work_orders.order(:assigned_date)
  end

  def show
  end

  def new
    @work_order = WorkOrder.new
    # Auto-set assign date to current date and current user as work assigner
    @work_order.assigned_date = Date.current
    @work_order.assigned_by = current_user.id
    
    @teams = VolunteersTeam.all
    @users = User.where(role: "admin")
  end

  def create
    @work_order = WorkOrder.new(work_order_params)
    
    # Ensure assign date and work assigner are set even if not provided in params
    @work_order.assigned_date ||= Date.current
    @work_order.assigned_by ||= current_user.id

    if @work_order.save
      # Notify team admins/volunteers and the assigner about the new work order
      begin
        # Prefer iterating team assignments -> volunteer -> user for robustness
        volunteers_team = @work_order.volunteers_team
        if volunteers_team.present?
          volunteers_team.team_assignments.includes(:volunteer).find_each do |assignment|
            volunteer = assignment.volunteer
            user = volunteer&.user
            next unless user
            NotificationService.notify(
              recipient: user,
              actor: current_user,
              notifiable: @work_order,
              action: 'work_order_assigned',
              title: "New work order assigned",
              body: "#{@work_order.title} assigned for #{@work_order.assigned_date.strftime('%B %d, %Y')}."
            )
          end
        end

        # Notify the user who assigned the work order
        if @work_order.assigned_by.present?
          assigner = User.find_by(id: @work_order.assigned_by)
          NotificationService.notify(
            recipient: assigner || current_user,
            actor: current_user,
            notifiable: @work_order,
            action: 'work_order_created',
            title: "Work order created",
            body: "You created a work order: #{@work_order.title}."
          )
        end
      rescue => e
        Rails.logger.error("Notification error (work order create): #{e.message}")
      end

      redirect_to @work_order, notice: "Work order was successfully created and assigned to you for #{@work_order.assigned_date.strftime('%B %d, %Y')}."
    else
      @teams = VolunteersTeam.all
      @users = User.where(role: "admin")
      render :new
    end
  end

  def edit
    @teams = VolunteersTeam.all
    @users = User.where(role: "admin")
  end

  def update
    if @work_order.update(work_order_params)
      # Notify assigned team members about the update
      begin
        team_members = @work_order.volunteers_team&.users
        if team_members.present?
          team_members.find_each do |member|
            NotificationService.notify(
              recipient: member,
              actor: current_user,
              notifiable: @work_order,
              action: 'work_order_updated',
              title: "Work order updated",
              body: "#{@work_order.title} was updated."
            )
          end
        end
      rescue => e
        Rails.logger.error("Notification error (work order update): #{e.message}")
      end

      redirect_to @work_order, notice: "Work order was successfully updated."
    else
      @teams = VolunteersTeam.all
      @users = User.where(role: "admin")
      render :edit
    end
  end

  def destroy
    @work_order.destroy
    redirect_to work_orders_url, notice: "Work order was successfully deleted."
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:id])
  end

  def work_order_params
    params.require(:work_order).permit(:team_id, :title, :description, :checklist, :assigned_date, :assigned_by)
  end
end
