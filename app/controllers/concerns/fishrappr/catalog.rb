require 'fishrappr/search_state'

module Fishrappr::Catalog
  extend ActiveSupport::Concern

  include Blacklight::Base

  included do
    helper_method :process_highlighted_words
    helper_method :highlights_available?
    helper_method :highlights_visible?
    helper_method :container_classes

    setup_browse_defaults_hack
    record_search_parameters only: [ :index, :browse ]
  end

  module ClassMethods
    def setup_browse_defaults_hack
      before_action :set_browse_defaults, only: :browse
    end
  end

  def search_results(user_params)
    if user_params["date_filter"] and user_params["date_filter"] != 'any'
      user_params["date_filter_options"] = get_date_params(user_params)
    end
    # binding.pry
    super
  end

  # get search results from the solr index
  def index

    (@response, @document_list) = search_results(params)
    respond_to do |format|
      format.html { } # no longer store_preferred_view
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
    @raw_layout = true
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
      format.html { setup_next_and_previous_documents; setup_next_and_previous_issue_pages; setup_issue_data }
      format.json { render json: { response: { document: @document } } }

      additional_export_formats(@document, format)
    end
  end

  def toggle_highlight
    session[:show_highlight] = true if session[:show_highlight].nil?
    session[:show_highlight] = not(session[:show_highlight])
    render json: { highlighting: session[:show_highlight] }
  end

  def download_text(document=nil)      
    @response, @document = fetch params[:id]
    document = @document unless document
    ocr = document.fetch('page_text')
    send_data ocr, filename: document.id+'.txt'
  end

   def download_issue_text(document=nil)      
    @response, @document = fetch params[:id]
    data = get_issue_data(['page_text'])
    get_page_data(data)   
  end

  def issue_data
    @response, @document = fetch params[:id]
    data = get_issue_data

    render json: data
  end

  def browse

    # build fq Array
    fq_arr = []

    unless (params["date_issued_yyyy10_ti"] == "Any Decade" || params["date_issued_yyyy10_ti"].blank?)
      fq_arr << "date_issued_yyyy10_ti:#{params['date_issued_yyyy10_ti']}"
    end

    unless (params["date_issued_yyyy_ti"] == "Any Year" || params["date_issued_yyyy_ti"].blank?)
      fq_arr << "date_issued_yyyy_ti:#{params['date_issued_yyyy_ti']}"
    end

    unless (params["date_issued_mm_ti"] == "Any Month" || params["date_issued_mm_ti"].blank?)
      fq_arr << "date_issued_mm_ti:#{params['date_issued_mm_ti']}"
    end

    unless (params["date_issued_dd_ti"] == "Any Day" || params["date_issued_dd_ti"].blank?)
      fq_arr << "date_issued_dd_ti:#{params['date_issued_dd_ti']}"
    end

    if fq_arr.empty?
      params[:date_issued_yyyy10_ti] = 'Any Decade'
    end

    # add sequence and publication to fq query
    fq_arr.unshift "publication_link:#{session[:publication]}"
    fq_arr.unshift "issue_sequence:1"

    search_params = {
      fl: blacklight_config.default_solr_params[:fl] + ",date_issued_dt,page_abstract",
      fq: fq_arr,
      sort: "date_issued_dt asc, sequence asc",
      group: true,
      'group.field': "date_issued_yyyymm_ti",
      'group.limit': 1000,
      'group.ngroups': true,
      start: (( params.fetch('page', '1').to_i - 1 ) * 10),
      rows: 10,
    }

    @response = repository.search(search_params)
    @response = @response.group("date_issued_yyyymm_ti")
  end

  def home

    @now = Time.now
    @featured_list = fetch_random(@now)
    if @featured_list.blank?
      @featured_list = fetch_random
    end
    @featured_list.sort_by!{ |document| document.fetch(:date_issued_dt) }

    render :layout => 'home'
  end

  # UTILITY

  def start_new_search_session?
    action_name == 'index' or action_name == 'browse'
  end

  # A list of query parameters that should not be persisted for a search
  def blacklisted_search_session_params
    [:commit, :counter, :total, :search_id, :per_page, :publication]
  end

  def fetch_random(time=nil)
    fq_arr = []

    # add sequence to fq hash
    fq_arr << "publication_link:#{session[:publication]}"
    fq_arr << "issue_sequence:1"

    # get month number and add to fq_arr
    unless time.nil?
      m = time.month
      fq_arr << "date_issued_mm_ti:#{m}";

      # ditto for day in month
      d = time.day
      fq_arr << "date_issued_dd_ti:#{d}";
    end

    params = {
      fl: blacklight_config.default_solr_params[:fl] + ",date_issued_dt",
      fq: fq_arr,
      # sort: "date_issued_dt asc, sequence asc",
      sort: "random_#{Time.now.to_i} asc",
      rows: 3
    }

    response = repository.search(params)
    response.documents
  end

  def fetch_in_context(params, search_query)
    fq = []
    fq_param = {}
    [ :publication_link, :ht_barcode, :date_issued_link, :issue_sequence ].each do |key|
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

  def setup_issue_data
    @issue_data = get_issue_data
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
    # STDERR.puts "AHOY SEARCH STATE : #{@search_state} : #{@search_state.to_h unless @search_state.nil?}"
    @search_state ||= Fishrappr::SearchState.new(params, blacklight_config)
  end

  def process_highlighted_words(document=nil)
    document = @document unless document
    words = {}
    if document.highlight_field('page_text')
      non_lexemes = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")
      document.highlight_field('page_text').each do |text|
        text.scan(/\[\[\[\[.+?\]\]\]\]/).each do |word|
          word.gsub!('[[[[', '').gsub!(']]]]', '')
          word = word.gsub(non_lexemes, '')
          next unless word.strip and words[word.strip].nil?
          words[word.strip.downcase] = true
        end
      end
    end
    words.keys.sort.to_json
  end

  # this is crazy stuff

  
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

    def get_page_data(data)

      require 'zip'
      require 'tempfile'

      fname =  data[:id]+".zip"
      tmpname = "tmp_zip.zip"
      tmp_file = Tempfile.new(tmpname)
      readme_txt = "The Michigan Daily"
      Zip::File.open(tmp_file.path, Zip::File::CREATE) {
        |zipfile|
        zipfile.get_output_stream(data[:id] + '/' + 'readme.txt') { |f| f.puts readme_txt }
        data[:pages].each do |page|
          zipfile.get_output_stream(data[:id] + '/' + page[:id] + ".txt") { |f| f.puts page[:page_text] }
        end
      }
      
      send_file tmp_file.path, filename:fname
      tmp_file.close
    end
      
    def container_classes
      @container_fluid ? 'container-fluid' : 'container'
    end

    

    def get_issue_data(flds=[])
      # need to find all the issues for this issue
      ht_namespace = @document.fetch('ht_namespace')
      ht_barcode = @document.fetch('ht_barcode')

      fl = [ 'id', 'sequence', 'text_link', 'img_link', flds].flatten.compact
      params = {
        fl: fl.join(','),
        fq: [ "ht_namespace:#{ht_namespace}", "ht_barcode:#{ht_barcode}", "issue_sequence:#{@document.fetch('issue_sequence')}", "date_issued_link:#{@document.fetch('date_issued_link')}" ],
        sort: "sequence asc",
        rows: 500
      }

      solr_response = repository.search(params)
      data = {}
      data[:barcode] =  "#{ht_namespace}.#{ht_barcode}"
      data[:pages] = []

      solr_response.documents.each do |document|
        datum = {}
        fl.each do |fld|
          datum[fld.to_sym] = document[fld]
        end
        datum[:seq] = datum[:text_link].gsub(/[^\d]+/, '').to_i
        
        data[:pages] << datum
      end

      # this is stupid
      tmp = data[:pages][0][:id].split("-")
      tmp.pop
      data[:id] = tmp.join('-')
      data
    end

    def resolve_layout
      case action_name
      when "show"
        "pageview"
      else
        "blacklight"
      end
    end

    def get_date_params(user_params)
      retval = {}
      user_params.keys.each do |key|
        if key.start_with?('date_issued_')
          if user_params[key] == '-' or user_params[key].match(/^\d+/).nil?
            user_params[key] = nil
          end
        end
      end

      [ 'begin', 'end' ].each do |suffix|
        unless user_params["date_issued_#{suffix}_yyyy"].blank?
          retval[suffix] = {}
          tmp = [ user_params["date_issued_#{suffix}_yyyy"] ]
          unless user_params["date_issued_#{suffix}_mm"].blank?
            tmp << user_params["date_issued_#{suffix}_mm"]
            unless user_params["date_issued_#{suffix}_dd"].blank?
              tmp << user_params["date_issued_#{suffix}_dd"]
            end
          end
          tmp.compact!
          tmp[0] = "%04d" % tmp[0] if tmp[0]
          tmp[1] = "%02d" % tmp[1] if tmp[1]
          tmp[2] = "%02d" % tmp[2] if tmp[2]
          retval[suffix][:value] = tmp.join
          case tmp.size
          when 1
            retval[suffix][:fld] = 'date_issued_yyyy_ti'
          when 2
            retval[suffix][:fld] = 'date_issued_yyyymm_ti'
          else
            retval[suffix][:fld] = 'date_issued_yyyymmdd_ti'
          end
        end
      end
      if retval['begin'] and retval['end']
        from_key = to_key = nil
        if retval['begin'][:fld] > retval['end'][:fld]
          from_key = 'begin'
          to_key = 'end'
        elsif retval['begin'][:fld] < retval['end'][:fld]
          from_key = 'end'
          to_key = 'begin'
        end

        if from_key and to_key
          retval[from_key][:fld] = retval[to_key][:fld]
          retval[from_key][:value] = retval[from_key][:value][ 0 .. retval[to_key][:value].size - 1 ]
        end
      end
      retval
    end
    
    def set_browse_defaults
      if params.reject { |k,v| [:action, :controller].include? k.to_sym }.blank?
        params['date_issued_yyyy10_ti'] = 'Any Decade'
        STDERR.puts "SETTING UP THE DEFAULT BROWSE"
      end
    end
end