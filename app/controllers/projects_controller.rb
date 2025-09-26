require "ostruct"

class ProjectsController < ApplicationController
  require "ostruct"
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

    # Recent donors for the donors tab (limit 30)
    @recent_donors = @project.donations.includes(:user).order(created_at: :desc).limit(30)

    # Impact items: if the project has expenses or other impact data, use them; otherwise provide simple placeholders
    if @project.respond_to?(:impact_items) && @project.impact_items.respond_to?(:limit)
      @impact_items = @project.impact_items.order(created_at: :desc).limit(10)
    else
      # Fallback: derive impacts from recent expenses
      @impact_items = @project.expenses.order(created_at: :desc).limit(10).map do |e|
        # Expense model has `title` and `amount` (no `description`/`category`).
        title = e.respond_to?(:title) ? e.title : "Expense: $#{e.amount}"
        summary_parts = [ "Spent $#{e.amount}" ]
        summary_parts << "on #{e.title}" if e.respond_to?(:title) && e.title.present?
        OpenStruct.new(title: title, summary: summary_parts.join(" "), created_at: e.created_at)
      end
      # If still empty, supply a few static items
      if @impact_items.empty?
        @impact_items = [
          OpenStruct.new(title: "Community meals delivered", summary: "Provided hot meals to 200 families.", created_at: 1.day.ago),
          OpenStruct.new(title: "Medical camp", summary: "Organized a medical camp for 150 patients.", created_at: 7.days.ago)
        ]
      end
    end

  # More projects to show in the small-cards carousel (exclude current project)
  @more_projects = Project.active.where.not(id: @project.id).order(created_at: :desc).limit(12)
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
    # track who created/updated this project
    if current_user
      @project.updated_by = current_user
      @project.updated_by_name = "#{current_user.first_name} #{current_user.last_name}" rescue nil
    end

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
      # track updater
      if current_user
        @project.updated_by = current_user
        @project.updated_by_name = "#{current_user.first_name} #{current_user.last_name}" rescue nil
      end
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
      params.require(:project).permit(:name, :categories, :description, :is_active, :image, :donation_title, :donation_subtitle)
    end
end
