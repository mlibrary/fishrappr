module Fishrappr::Context
  extend ActiveSupport::Concern

  def setup_publication
    puts "In setup_publication params are: #{params}"
    if params[:publication]
      session[:publication] = params[:publication]
    else
      session[:publication] ||= Settings.default_publication
      params[:publication] = session[:publication]
    end
    @publication = Publication.where(slug: session[:publication]).first
    if session[:publication] == "djnews"
      @page_title = @publication_name = "Detroit Jewish News"
    elsif session[:publication] == "midaily"
      @page_title = @publication_name = "Michigan Daily"
    else
      @page_title = @publication_name = "Bentley Archive"
    end
  end

end
