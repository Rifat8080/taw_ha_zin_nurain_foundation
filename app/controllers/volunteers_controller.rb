class VolunteersController < ApplicationController
  before_action :set_volunteer, only: [ :show, :edit, :update, :destroy ]

  def index
    @volunteers = Volunteer.includes(:user, :volunteers_teams).all
    @volunteers = @volunteers.by_role(params[:role]) if params[:role].present?
  end

  def show
    @team_assignments = @volunteer.team_assignments.includes(:volunteers_team)
  end

  def new
    @volunteer = Volunteer.new
    @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil })
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)

    if @volunteer.save
      redirect_to @volunteer, notice: "Volunteer was successfully created."
    else
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil })
      render :new
    end
  end

  def edit
    @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil }).or(User.where(id: @volunteer.user_id))
  end

  def update
    if @volunteer.update(volunteer_params)
      redirect_to @volunteer, notice: "Volunteer was successfully updated."
    else
      @available_users = User.left_joins(:volunteer).where(volunteers: { id: nil }).or(User.where(id: @volunteer.user_id))
      render :edit
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: "Volunteer was successfully deleted."
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:volunteer).permit(:user_id, :joining_date, :role)
  end
end
