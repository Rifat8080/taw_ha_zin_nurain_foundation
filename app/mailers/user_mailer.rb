class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset instructions"
  end

  def welcome_donor(user, temp_password)
    @user = user
    @temp_password = temp_password
    mail to: user.email, subject: "Thank you for your donation - Account Created"
  end
end