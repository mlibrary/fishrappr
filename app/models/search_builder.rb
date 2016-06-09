# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :filter_by_publication]
  include BlacklightRangeLimit::RangeLimitBuilder

  def filter_by_publication(solr_parameters)
    solr_parameters[:fq] ||= []
    publication = blacklight_params['publication'] || Rails.configuration.default_publication
    solr_parameters[:fq] << "{!term f=publication_link}#{publication}"
  end

end