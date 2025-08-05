class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.present?
      # Send email
      @user.update(reset_password_token: SecureRandom.urlsafe_base64, reset_password_sent_at: Time.zone.now)
      UserMailer.password_reset(@user).deliver_now
      redirect_to root_path, notice: "If an account with that email exists, we have sent a link to reset your password."
    else
      redirect_to root_path, notice: "If an account with that email exists, we have sent a link to reset your password."
    end
  end

  def edit
    @user = User.find_by(reset_password_token: params[:id])
    redirect_to root_path, alert: "Invalid password reset token." unless @user && @user.reset_password_sent_at > 2.hours.ago
  end

  def update
    @user = User.find_by(reset_password_token: params[:id])
    if @user && @user.reset_password_sent_at > 2.hours.ago
      if @user.update(password_params)
        @user.update(reset_password_token: nil, reset_password_sent_at: nil)
        redirect_to root_path, notice: "Your password has been reset successfully."
      else
        render :edit
      end
    else
      redirect_to new_password_reset_path, alert: "Password reset has expired."
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end