require 'fishrappr/search_state'
module Fishrappr::Catalog
  extend ActiveSupport::Concern

  include Blacklight::Base

  # get a single document from the index
  # to add responses for formats other than html or json see _Blacklight::Document::Export_

  def search_results(user_params)
    
    user_params["range"] = {"date_issued_yyyymmdd_ti"=>{"begin"=>"", "end"=>""}} if user_params["range_start"] || user_params["range_end"]
    
    if user_params["range_start"]
      user_params["range_start"]= user_params["range_start"].gsub('-','')
      user_params["range"]["date_issued_yyyymmdd_ti"]["begin"] = user_params["range_start"] 
    end
    
    if user_params["range_end"]
      user_params["range_end"]= user_params["range_end"].gsub('-','')
      user_params["range"]["date_issued_yyyymmdd_ti"]["end"] = user_params["range_end"] if user_params["range_end"]
    end
    super
  end  

  def show
    if params[:id]
      @response, @document = fetch params[:id]
    elsif params[:ht_barcode]
      @response, @document = fetch_in_context params
    end

    respond_to do |format|
      format.html { setup_next_and_previous_documents; setup_next_and_previous_issue_pages }
      format.json { render json: { response: { document: @document } } }

      additional_export_formats(@document, format)
    end
  end

  def fetch_in_context(params)
    fq = []
    [ :publication_link, :ht_barcode, :date_issued_link, :sequence ].each do |key|
      fq << %{#{key}:"#{params[key]}"}
    end
    solr_response = repository.search fq: fq, fl: '*'
    [solr_response, solr_response.documents.first]
  end

  def setup_next_and_previous_issue_pages
    @previous_page = @next_page = nil
    begin
      response, @previous_page = fetch @document.fetch('prev_page_link')
    rescue Exception => e
      STDERR.puts "PREVIOUS : #{e}"
    end
    begin
      response, @next_page = fetch @document.fetch('next_page_link')
    rescue Exception => e
      STDERR.puts "NEXT : #{e}"
    end
    # response, documents = get_previous_and_next_documents_for_issue_page sequence, ActiveSupport::HashWithIndifferentAccess.new(current_search_session.query_params)
    # @search_page_response = response
    # @previous_page = documents.first
    # @next_page = document.last
  rescue Blacklight::Exceptions::InvalidRequest => e
    logger.warn "Unable to setup next and previous documents: #{e}"
  end

  def repository
    @repository ||= repository_class.new(blacklight_config)
  end

  def search_state
    # binding.pry
    @search_state ||= Fishrappr::SearchState.new(params, blacklight_config)
  end

end
