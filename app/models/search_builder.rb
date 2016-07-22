# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :add_date_range_limit_params, :filter_by_publication]
  # include BlacklightRangeLimit::RangeLimitBuilder

  def filter_by_publication(solr_parameters)
    solr_parameters[:fq] ||= []
    publication = blacklight_params['publication'] || Rails.configuration.default_publication
    solr_parameters[:fq] << "{!term f=publication_link}#{publication}"
  end

  def add_date_range_limit_params(solr_parameters)
    date_filter = blacklight_params['date_filter'] || 'any'
    return if date_filter == 'any'
    # if date_filter == 'any'
    #   solr_parameters[:fq] ||= []
    #   solr_parameters[:fq] << "date_issued_yyyy_ti:[* TO *]"
    #   blacklight_params[:ranage] = { start: '*', finish: '*' }
    #   STDERR.puts "APPLYING WHOLE FILTER"
    #   return
    # end

    options = blacklight_params["date_filter_options"] #get_date_params(blacklight_params)
    return if options.blank? or options.empty?
    # return unless options['begin']

    return if date_filter == 'between' and options['end'].nil?

    fq = nil
    solr_parameters[:fq] ||= []
    case date_filter
    when 'before'
      fq = "#{options['begin'][:fld]}:[* TO #{options['begin'][:value]}]"
    when 'after'
      fq = "#{options['begin'][:fld]}:[#{options['begin'][:value]} TO *]"
    when 'on'
      fq = "#{options['begin'][:fld]}:#{options['begin'][:value]}"
    when 'between'
      fq = "#{options['begin'][:fld]}:[#{options['begin'][:value]} TO #{options['end'][:value]}]"
    end

    solr_parameters[:fq] << fq if fq
  end

  private


end