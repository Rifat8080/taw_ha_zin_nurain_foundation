class ApplicationController < ActionController::Base
  include LocaleAware
  include PerformanceMonitoring

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :public_action?
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :determine_layout

  def switch_language
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end

  private

  def determine_layout
    if public_action?
      "public"
    elsif user_signed_in?
      "authenticated"
    else
      "public"
    end
  end

  def public_action?
    # Define which controllers/actions should use the public layout
    public_controllers = %w[home pages]
    devise_controllers = controller_name.start_with?("devise/")

    # Allow public access to certain pages
    # Only treat home#index as public, not dashboard
    return true if controller_name == "home" && action_name == "index"
    return true if devise_controllers

    # Always use public layout for these resources' index/show actions, for all users
    return true if controller_name == "healthcare_requests" && action_name.in?(%w[index show])
    return true if controller_name == "events" && action_name.in?(%w[index show])
    return true if controller_name == "projects" && action_name.in?(%w[index show])

    # Allow public access to about, gallery, and contact pages
    if controller_name == "pages" && action_name.in?(%w[about gallery contact])
      return true
    end

    # Allow public access to switch_language action
    return true if controller_name == "application" && action_name == "switch_language"

    false
  end

  def require_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone_number, :role, :address ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone_number, :role, :address ])
  end
end
