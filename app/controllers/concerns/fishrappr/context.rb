module Fishrappr::Context
  extend ActiveSupport::Concern

  def setup_publication
    if params[:publication]
      session[:publication] = params[:publication] # || Rails.configuration.default_publication
    else
      session[:publication] ||= Rails.configuration.default_publication
      params[:publication] = session[:publication]
    end
    @publication = Publication.where(slug: session[:publication]).first
  end


end