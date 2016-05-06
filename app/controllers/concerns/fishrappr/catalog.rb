require 'fishrappr/search_state'
module Fishrappr::Catalog
  extend ActiveSupport::Concern

  include Blacklight::Base

  def browse_issue_page
    @response, @document = fetch_issue params[:issue_date], params[:sequence]
    setup_next_and_previous_documents; setup_next_and_previous_issue_pages
    render "show"
  end

  # get a single document from the index
  # to add responses for formats other than html or json see _Blacklight::Document::Export_
  def show
    @response, @document = fetch params[:id]

    respond_to do |format|
      format.html { setup_next_and_previous_documents; setup_next_and_previous_issue_pages }
      format.json { render json: { response: { document: @document } } }

      additional_export_formats(@document, format)
    end
  end

  def fetch_issue(issue_date, sequence, extra_controller_params={})
    fq = [ %Q{issue_date_dt:"#{issue_date.to_date.strftime("%Y-%m-%dT00:00:00Z")}"}, "sequence_i:#{sequence}" ]
    # solr_response = repository.search fq: [ "issue_date_dt" => issue_date.to_date.strftime("%Y-%m-%dT00:00:00Z"), "sequence_i" => sequence ], fl: '*'
    solr_response = repository.search fq: fq, fl: '*'
    [solr_response, solr_response.documents.first]
  end

  def setup_next_and_previous_issue_pages
    sequence = @document.fetch('sequence_i')
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
