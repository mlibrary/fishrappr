module Fishrappr::Context
  extend ActiveSupport::Concern

  def setup_publication
    # this is dumb
    # params.permit(:search_field, :q, :publication, :date_filter, :date_issued_begin_mm, :date_issued_begin_dd, :date_issued_begin_yyyy, :date_issued_end_mm, :date_issued_end_dd, :date_issued_end_yyyy, :issue_identifier)
    user_params = params

    if user_params[:publication]
      session[:publication] = user_params[:publication]
    else
      session[:publication] ||= Settings.default_publication
      params[:publication] = session[:publication]
    end
    @publication = Publication.where(slug: session[:publication]).first

    @publication_name = @publication.title
  end
end
