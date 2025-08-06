class TeamAssignmentsController < ApplicationController
  before_action :set_team_assignment, only: [ :show, :destroy ]

  def index
    @team_assignments = TeamAssignment.includes(:volunteer, :volunteers_team).all
    @team_assignments = @team_assignments.by_volunteer(params[:volunteer_id]) if params[:volunteer_id].present?
    @team_assignments = @team_assignments.by_team(params[:team_id]) if params[:team_id].present?
  end

  def show
  end

  def new
    @team_assignment = TeamAssignment.new
    # Pre-select volunteer if coming from volunteer profile
    @team_assignment.volunteer_id = params[:volunteer_id] if params[:volunteer_id].present?
    
    @volunteers = Volunteer.includes(:user).all
    @teams = VolunteersTeam.all
  end

  def create
    @team_assignment = TeamAssignment.new(team_assignment_params)

    if @team_assignment.save
      redirect_to @team_assignment, notice: "Team assignment was successfully created."
    else
      # Log the errors for debugging
      Rails.logger.error "TeamAssignment creation failed: #{@team_assignment.errors.full_messages.join(', ')}"
      Rails.logger.error "Params: #{team_assignment_params.inspect}"
      
      @volunteers = Volunteer.includes(:user).all
      @teams = VolunteersTeam.all
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @team_assignment.destroy
    redirect_to team_assignments_url, notice: "Team assignment was successfully removed."
  end

  private

  def set_team_assignment
    @team_assignment = TeamAssignment.find(params[:id])
  end

  def team_assignment_params
    # Log the incoming parameters for debugging
    Rails.logger.info "Raw params: #{params.inspect}"
    permitted = params.require(:team_assignment).permit(:volunteer_id, :team_id)
    Rails.logger.info "Permitted params: #{permitted.inspect}"
    permitted
  end
end
