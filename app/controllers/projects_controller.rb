class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    if user_signed_in? && current_user.role == "admin"
      @projects = Project.all
    else
      @projects = Project.active
    end

    # Filter by category if specified
    if params[:filter].present? && params[:filter][:categories].present?
      category = params[:filter][:categories]
      @projects = @projects.where("categories ILIKE ?", "%#{category}%")
      @filter_category = category
    end

    # Search functionality
    if params[:search].present?
      @projects = @projects.where("name ILIKE ? OR description ILIKE ? OR categories ILIKE ?", 
                                  "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @projects = @projects.includes(:donations).order(created_at: :desc)
  end

  # GET /projects/1 or /projects/1.json
  def show
    @donations = @project.donations.includes(:user)
    @total_donations = @donations.sum(:amount)
    @expenses = @project.expenses
    @total_expenses = @expenses.sum(:amount)
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, status: :see_other, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :categories, :description, :project_status_active, :image)
    end
end
