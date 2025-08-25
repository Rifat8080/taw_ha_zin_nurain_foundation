class HealthcareRequestsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_healthcare_request, only: [ :show, :edit, :update, :destroy, :approve, :reject, :complete ]

  def index
    @healthcare_requests = HealthcareRequest.includes(:user, :healthcare_donations).order(created_at: :desc)
    if params[:status].present?
      @filter_status = params[:status]
      @healthcare_requests = @healthcare_requests.by_status(@filter_status)
    end
    if params[:search].present?
      @healthcare_requests = @healthcare_requests.search(params[:search])
    end
  end

  def show
    @healthcare_donations = @healthcare_request.healthcare_donations.includes(:user).recent
    @new_donation = HealthcareDonation.new
  end

  def new
    @healthcare_request = current_user.healthcare_requests.build
  end

  def create
    @healthcare_request = current_user.healthcare_requests.build(healthcare_request_params)

    if @healthcare_request.save
      redirect_to @healthcare_request, notice: "Healthcare request was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Only allow users to edit their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == "admin"
      redirect_to healthcare_requests_path, alert: "You are not authorized to edit this request."
      nil
    end
  end

  def update
    # Only allow users to edit their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == "admin"
      redirect_to healthcare_requests_path, alert: "You are not authorized to update this request."
      return
    end

    # Get the parameters
    request_params = healthcare_request_params

    # Auto-approve if admin sets status to approved
    if current_user.role == "admin" && request_params[:status] == "approved"
      request_params = request_params.merge(approved: true)
    elsif current_user.role == "admin" && request_params[:status] == "rejected"
      request_params = request_params.merge(approved: false)
    end

    if @healthcare_request.update(request_params)
      redirect_to @healthcare_request, notice: "Healthcare request was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow users to delete their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == "admin"
      redirect_to healthcare_requests_path, alert: "You are not authorized to delete this request."
      return
    end

    @healthcare_request.destroy
    redirect_to healthcare_requests_path, notice: "Healthcare request was successfully deleted."
  end

  def approve
    authorize_admin!
    @healthcare_request.approve!
    redirect_to @healthcare_request, notice: "Healthcare request has been approved."
  end

  def reject
    authorize_admin!
    @healthcare_request.reject!
    redirect_to @healthcare_request, notice: "Healthcare request has been rejected."
  end

  def complete
    authorize_admin!
    @healthcare_request.mark_as_completed!
    redirect_to @healthcare_request, notice: "Healthcare request has been marked as completed."
  end

  private

  def set_healthcare_request
    @healthcare_request = HealthcareRequest.find(params[:id])
  end

  def healthcare_request_params
    if current_user.role == "admin"
      params.require(:healthcare_request).permit(:patient_name, :reason, :prescription_url, :status, :approved)
    else
      params.require(:healthcare_request).permit(:patient_name, :reason, :prescription_url)
    end
  end

  def authorize_admin!
    unless current_user.role == "admin"
      redirect_to healthcare_requests_path, alert: "You are not authorized to perform this action."
    end
  end
end
