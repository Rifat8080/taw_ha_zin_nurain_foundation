class ApplicationController < ActionController::Base
  include LocaleAware
  include PerformanceMonitoring

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :public_action?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_layout_mode

  layout :determine_layout

  def switch_language
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end

  private

  def determine_layout
    # For specific resources we allow the user's current layout context
    # to decide whether the index/show is rendered inside the public
    # layout or the authenticated layout. This respects where the user
    # is currently browsing (public site vs authenticated app).
    if controller_name.in?(%w[events projects healthcare_requests]) && action_name.in?(%w[index show])
      if session[:layout_mode] == "authenticated" && user_signed_in?
        "authenticated"
      else
        "public"
      end
    else
      if public_action?
        "public"
      elsif user_signed_in?
        "authenticated"
      else
        "public"
      end
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
  # These resources are accessible publicly, but layout selection is
  # handled by `determine_layout` which will consult the session
  # layout_mode to decide between public/authenticated rendering.
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

  # Track the user's current layout context so we can render shared
  # index pages (events/projects/healthcare_requests) inside the UI
  # the user is currently using. We only set the mode to
  # 'authenticated' when the user visits authenticated-only areas.
  # For public landing pages (home, pages, devise) we set 'public'.
  def track_layout_mode
    # Honor explicit layout override in params first. Useful for links
    # inside the authenticated UI that should keep the authenticated layout
    # when navigating to shared pages.
    if params[:layout].present?
      if params[:layout] == "authenticated" && user_signed_in?
        session[:layout_mode] = "authenticated"
      elsif params[:layout] == "public"
        session[:layout_mode] = "public"
      end
      return
    end

    # If the user is navigating authenticated parts of the app, prefer that
    if !public_action? && user_signed_in?
      session[:layout_mode] = "authenticated"
      return
    end

    # Explicit public landing pages should set the public mode.
    if controller_name == "home" && action_name == "index"
      session[:layout_mode] = "public"
      return
    end

    if controller_name == "pages" && action_name.in?(%w[about gallery contact])
      session[:layout_mode] = "public"
      nil
    end

    # Keep existing session[:layout_mode] if present for ambiguous pages
  end

  def require_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone_number, :role, :address, :avatar ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone_number, :role, :address, :avatar ])
  end
end
