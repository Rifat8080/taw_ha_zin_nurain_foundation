class VolunteersTeamsController < ApplicationController
  before_action :set_volunteers_team, only: [ :show, :edit, :update, :destroy ]

  def index
    @volunteers_teams = VolunteersTeam.includes(:volunteers, :work_orders).all
    @volunteers_teams = @volunteers_teams.by_district(params[:district]) if params[:district].present?
  end

  def show
    @team_volunteers = @volunteers_team.volunteers.includes(:user)
    @work_orders = @volunteers_team.work_orders.includes(:assigned_by_user).order(:assigned_date)
    @team_assignments = @volunteers_team.team_assignments.includes(volunteer: :user)
  end

  def new
    @volunteers_team = VolunteersTeam.new
  end

  def create
    @volunteers_team = VolunteersTeam.new(volunteers_team_params)

    if @volunteers_team.save
      redirect_to @volunteers_team, notice: "Team was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @volunteers_team.update(volunteers_team_params)
      redirect_to @volunteers_team, notice: "Team was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @volunteers_team.destroy
    redirect_to volunteers_teams_url, notice: "Team was successfully deleted."
  end

  private

  def set_volunteers_team
    @volunteers_team = VolunteersTeam.find(params[:id])
  end

  def volunteers_team_params
    params.require(:volunteers_team).permit(:name, :district)
  end
end
