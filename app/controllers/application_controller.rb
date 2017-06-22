class ApplicationController < ActionController::Base
  add_flash_types :error, :success, :notice
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Fishrappr::Context
  # Behavior for devise.  Use remote user field in http header for auth.
  include Devise::Behaviors::HttpHeaderAuthenticatableBehavior
  
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :clear_session_user

  # saves the location before loading each page so we can return to the
  # right page. If we're on a devise page, we don't want to store that as the
  # place to return to (for example, we don't want to return to the sign in page
  # after signing in), which is what the :unless prevents
  before_action :store_current_location, :unless => :devise_controller? || :sessions_controller?
  

  before_action :setup_publication

  # From PSU's ScholarSphere
  # Clears any user session and authorization information by:
  #   * ensuring the user will be logged out if REMOTE_USER is not set
  # 14June17 GML Modified to restore fishrappr session essentials
  def clear_session_user
    return nil_request if request.nil?
    
    search = session[:search].dup if session[:search]
    publication = session[:publication].dup if session[:publication]
    user_return_to = session[:user_return_to].dup if session[:user_return_to]
    mynotice = flash[:notice]
    
    request.env['warden'].logout unless user_logged_in?
    
    session[:search] = search
    session[:publication] = publication
    session[:user_return_to] = user_return_to
    flash[:notice] = mynotice
  end

  def user_logged_in?
    user_signed_in? && ( valid_user?(request.headers) || Rails.env.test?)
  end
  
  def sso_logout
    redirect_to Blacklight::Engine.config.logout_prefix + logout_now_url
  end
  
  def sso_auto_logout
    Rails.logger.debug "[AUTHN] sso_auto_logout: #{current_user.try(:email) || '(no user)'}"
    sign_out(:user)
    cookies.delete("cosign-" + request.host, path: '/')
    session.destroy
    flash.clear
  end
  
  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.debug "[AUTHN] Warden after_authentication (clearing flash): #{user}"
    auth.request.flash.clear
  end
  
  private
  
  # from: https://github.com/plataformatec/devise/wiki/how-to:-redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  # If your model is called User
  # 15June2017 GML The unless cause keeps fishrappr 
  # from getting lost in redirects
  def store_current_location
    Rails.logger.debug "[AUTHN] CALLED store_current_location"
    Rails.logger.debug "[AUTHN] REQUEST URL IS: #{request.url}"
    store_location_for(:user, request.url) unless ( request.url == "http://localhost:3000/login" || request.url == "http://localhost:3000/login_info" || request.url == "http://localhost:3000/go_back" )
  end

end
