class HealthcareRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_healthcare_request, only: [:show, :edit, :update, :destroy, :approve, :reject]
  
  def index
    @healthcare_requests = HealthcareRequest.includes(:user, :healthcare_donations)
                                          .order(created_at: :desc)
                                          .page(params[:page])
    
    # Filter by status if provided
    @healthcare_requests = @healthcare_requests.by_status(params[:status]) if params[:status].present?
    
    # Filter by approval status if provided
    if params[:approved].present?
      @healthcare_requests = @healthcare_requests.where(approved: params[:approved] == 'true')
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
      redirect_to @healthcare_request, notice: 'Healthcare request was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Only allow users to edit their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == 'admin'
      redirect_to healthcare_requests_path, alert: 'You are not authorized to edit this request.'
      return
    end
  end

  def update
    # Only allow users to edit their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == 'admin'
      redirect_to healthcare_requests_path, alert: 'You are not authorized to update this request.'
      return
    end
    
    if @healthcare_request.update(healthcare_request_params)
      redirect_to @healthcare_request, notice: 'Healthcare request was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow users to delete their own requests or admins
    unless @healthcare_request.user == current_user || current_user.role == 'admin'
      redirect_to healthcare_requests_path, alert: 'You are not authorized to delete this request.'
      return
    end
    
    @healthcare_request.destroy
    redirect_to healthcare_requests_path, notice: 'Healthcare request was successfully deleted.'
  end
  
  def approve
    authorize_admin!
    @healthcare_request.approve!
    redirect_to @healthcare_request, notice: 'Healthcare request has been approved.'
  end
  
  def reject
    authorize_admin!
    @healthcare_request.reject!
    redirect_to @healthcare_request, notice: 'Healthcare request has been rejected.'
  end

  private

  def set_healthcare_request
    @healthcare_request = HealthcareRequest.find(params[:id])
  end

  def healthcare_request_params
    params.require(:healthcare_request).permit(:patient_name, :reason, :prescription_url, :status)
  end
  
  def authorize_admin!
    unless current_user.role == 'admin'
      redirect_to healthcare_requests_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
