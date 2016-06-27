require 'fishrappr/search_state'

module Fishrappr::Catalog
  extend ActiveSupport::Concern

  include Blacklight::Base

  included do
    helper_method :process_highlighted_words
    helper_method :highlights_available?
    helper_method :highlights_visible?
  end

  def search_results(user_params)
    

    start_len=end_len = 0

    start_len = user_params["range_start"].length if user_params["range_start"]
    end_len = user_params["range_end"].length if user_params["range_end"]    
    
    if start_len==4 || end_len==4
      user_params["range"] = {"date_issued_yyyy_ti"=>{"begin"=>"", "end"=>""}} 
      user_params["range"]["date_issued_yyyy_ti"]["begin"] = user_params["range_start"] 
      user_params["range"]["date_issued_yyyy_ti"]["end"] = user_params["range_end"] 
    elsif start_len>=8 || end_len >=8
      user_params["range_start"]= user_params["range_start"].gsub('-','')
      user_params["range"] = {"date_issued_yyyymmdd_ti"=>{"begin"=>"", "end"=>""}} 
      user_params["range"]["date_issued_yyyymmdd_ti"]["begin"] = user_params["range_start"] 
      user_params["range_end"]= user_params["range_end"].gsub('-','')
      user_params["range"]["date_issued_yyyymmdd_ti"]["end"] = user_params["range_end"] 
    end

    # byebug

    super
  end  

  # get search results from the solr index
  def index
    (@response, @document_list) = search_results(params)
    respond_to do |format|
      format.html { store_preferred_view }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        @presenter = Blacklight::JsonPresenter.new(@response,
                                                   @document_list,
                                                   facets_from_request,
                                                   blacklight_config)
      end
      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def show
    search_params = current_search_session.try(:query_params)
    search_field = search_params ? search_params["q"] : nil
    if params[:id] and search_field
      @response, @document = fetch_with_highlights params[:id], search_field
      # still fighting with blacklight to build the right kind of query
      # for when the search_field does not apply to this page
      if @document.nil?
        @response, @document = fetch params[:id]
      end
    elsif params[:id]
      @response, @document = fetch params[:id]
    elsif params[:ht_barcode]
      @response, @document = fetch_in_context params, search_field
    end

    @subview = get_view
    @subview = 'plaintext' if @document.fetch('img_link', nil).nil?
    
    respond_to do |format|
      format.html { setup_next_and_previous_documents; setup_next_and_previous_issue_pages }
      format.json { render json: { response: { document: @document } } }

      additional_export_formats(@document, format)
    end
  end

  def toggle_highlight
    session[:show_highlight] = true if session[:show_highlight].nil?
    session[:show_highlight] = not(session[:show_highlight])
    render json: { highlighting: session[:show_highlight] }
  end


  # UTILITY

  def fetch_in_context(params, search_query)
    fq = []
    fq_param = {}
    [ :publication_link, :ht_barcode, :date_issued_link, :sequence ].each do |key|
      fq << %{#{key}:"#{params[key]}"}
      fq_param[key.to_s] = params[key]
    end
    if search_query
      builder = ::DocumentSearchBuilder.new(self).with({ 
        :search_field => "advanced",
        :op => 'OR',
        :page_text => search_query,
        :ht_barcode => params[:ht_barcode],
        :"controller" => "catalog",
        :"action" => "index",
        :"f" => fq_param,
        :"rows" => 1
      })
      builder.rows(1)
      ## binding.pry

      solr_response = repository.search(builder)

    else
      solr_response = repository.search fq: fq, fl: '*'
    end
    [solr_response, solr_response.documents.first]
  end

  def fetch_with_highlights(id, search_query)
    fq = []
    fq_param = {}
    [ :id ].each do |key|
      fq << %{#{key}:"#{params[key]}"}
      fq_param[key.to_s] = params[key]
    end
    if search_query
      builder = ::DocumentSearchBuilder.new(self).with({ 
        :search_field => "advanced",
        :op => 'OR',
        :page_text => search_query,
        :ht_barcode => params[:ht_barcode] || params[:id].split('-').first,
        :"controller" => "catalog",
        :"action" => "index",
        :"f" => fq_param,
        :"rows" => 1
      })
      builder.rows(1)
      ## binding.pry


      solr_response = repository.search(builder)
    else
        solr_response = repository.search fq: fq, fl: '*'
    end
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

  def home
    query = search_builder.merge(rows: 0)
    @response = repository.search(query)
    render :layout => 'home'
  end

  def process_highlighted_words(document=nil)
    document = @document unless document
    words = {}
    if document.highlight_field('page_text')
      non_lexemes = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")
      document.highlight_field('page_text').each do |text|
        text.scan(/<span class="highlight">.+?<\/span>/).each do |word|
          word.gsub!('<span class="highlight">', '').gsub!('</span>', '')
          word = word.gsub(non_lexemes, '')
          next unless word.strip and words[word.strip].nil?
          words[word.strip.downcase] = true
        end
      end
    end
    words.keys.sort.to_json
  end

  private
    def setup_publication
      if params[:publication]
        session[:publication] = params[:publication] # || Rails.configuration.default_publication
      else
        session[:publication] ||= Rails.configuration.default_publication
        params[:publication] = session[:publication]
      end
    end

    def get_view
      session[:view] = params[:view] if params[:view]
      session[:view] ||= 'image'
    end

    def search_field
      search_params = current_search_session.try(:query_params)
      search_field = search_params ? search_params["q"] : nil
    end

    def highlights_available?
      not(search_field.nil?) and @document.has_highlight_field?(:page_text)
    end

    def highlights_visible?
      ! ( session[:show_highlight] == false )
    end

end
