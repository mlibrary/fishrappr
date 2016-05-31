require 'mail'
class StaticController < ApplicationController

  def home
     render :layout => 'home'
  end

  def search

    @search_params = Hash.new {''}
    @search_params['range_start'] = ( (params['home_search']['start_year']).to_s + "0101").to_i
    @search_params['range_end'] = ( (params['home_search']['end_year']).to_s + "1231").to_i
    @search_params['q'] = @search_text = params['home_search']['end_year']

    #redirect_to url_for(:controller => 'CatalogController', :action => 'search_results', :params => @search_params)

    redirect_to url_for(:controller => 'CatalogController', :action => 'search_results', :range_start => @search_params['range_start'], :range_end => @search_params['range_end'], :q => @search_params['q'])
    
  end
  
  def page

    @page = SolrDocument.new(
      {
        "id":"1",
        "issue_no_t":["1"],
        "issue_date_dt":"1899-09-23T00:00:00Z",
        "issueid_t":["2"],
        "page_no_t":["1"],
        "sequence_i":1,
        "hathitrust_t":["mdp.39015071730837"],
        "text_link_t":["TXT00000005"],
        "img_link_t":["IMG00000005"],
        "timestamp":"2016-04-27T16:03:28.035Z"
      }
    )

  end

end