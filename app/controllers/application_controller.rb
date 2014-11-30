class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  # TODO: Don't inject the username when it's not needed
  def url_options
    {
      username: params[:username] || (current_user.username rescue nil)
    }
    .merge(super)
  end

  # Redirect to the user's profile at login unless there's something stored
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || profile_path(current_user)
  end

  protected

  # This allows ?locale=XX in the URL. Not really implemented yet...
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
    end
  end

end
