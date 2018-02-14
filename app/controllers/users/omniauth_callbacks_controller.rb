class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_callback
    provider = __callee__

    auth = request.env['omniauth.auth']
    Rails.logger.info "Got #{provider} oauth response: #{auth}"
    @user = User.find_for_oauth(auth, current_user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :omniauth_callback
  alias_method :google, :omniauth_callback

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
