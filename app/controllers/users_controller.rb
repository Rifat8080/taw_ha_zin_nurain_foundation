class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :destroy]

  def index
    # Exclude users with volunteer role as they are shown in volunteers#index
    users = User.where.not(role: 'volunteer')

    if params[:q].present?
      q = params[:q].strip
      users = users.where("(first_name ILIKE :q) OR (last_name ILIKE :q) OR (email ILIKE :q) OR (role ILIKE :q)", q: "%#{q}%")
    end

    @users = users.order(created_at: :desc).page(params[:page])
  end
  
  def admin_index
    redirect_to users_path
  end

  def show
  end

  def edit
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
  params.require(:user).permit(:first_name, :last_name, :phone_number, :role, :address, :avatar, :email, :password, :password_confirmation)
  end
end