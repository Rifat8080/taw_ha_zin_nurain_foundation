class DonationsController < ApplicationController
  before_action :set_donation, only: [ :show, :edit, :update, :destroy ]

  def index
    @donations = Donation.includes(:user, :project).all
  end

  def show
  end

  def new
    @donation = Donation.new
    @donation.project_id = params[:project_id] if params[:project_id]
    @users = User.all
    @projects = Project.all
  end

  def create
    @donation = Donation.new(donation_params)

    if @donation.save
      redirect_to @donation, notice: "Donation was successfully created."
    else
      @users = User.all
      @projects = Project.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.all
    @projects = Project.all
  end

  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: "Donation was successfully updated."
    else
      @users = User.all
      @projects = Project.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @donation.destroy
    redirect_to donations_url, notice: "Donation was successfully deleted."
  end

  private

  def set_donation
    @donation = Donation.find(params[:id])
  end

  def donation_params
    params.require(:donation).permit(:amount, :user_id, :project_id)
  end
end
