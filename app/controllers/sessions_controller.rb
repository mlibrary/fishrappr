class SessionsController < ApplicationController
  layout 'static'

  def destroy
    if user_signed_in?
      sso_logout
    else
      logout_now
    end
  end
  
  def login_info
    Rails.logger.debug "[AUTHN] sessions#login_info, rendering"

    render 'login_info'
  end

  def go_back
    Rails.logger.debug "[AUTHN] sessions#go_back, redirecting"

    puts ">>> stored_location_for(:user) is #{stored_location_for(:user)}"

    redirect_to stored_location_for(:user) #|| root_path
  end

  def new
    if user_signed_in?
      Rails.logger.debug "[AUTHN] sessions#new, redirecting"
      # redirect to where user came from (see Devise::Controllers::StoreLocation#stored_location_for)
      # flash[:notice] = "You are now logged in."
      ### redirect_to stored_location_for(:user) || root_path
      target = stored_location_for(:user) || root_path
      target = "https://#{request.host}#{target}"

      redirect_to "#{Settings.DLXS_SERVICE_URL}/cgi/dlxslogin?target=#{CGI.escape(target)}"
    else
      Rails.logger.debug "[AUTHN] sessions#new, failed because user_signed_in? was false"
      # should have been redirected via mod_cosign - error out instead of going through redirect loop
      # render(:status => :forbidden, :text => 'Forbidden')
      flash[:notice] = "Sorry, login didn\'t work."
      # redirect_to stored_location_for(:user) || root_path
      redirect_to stored_location_for(:user) || root_path
    end
  end

  def logout_now
    Rails.logger.debug "[AUTHN] sessions#logout_now, redirecting"

    sso_auto_logout
    # redirect_to root_url
    redirect_to stored_location_for(:user) || root_path
  end
end
