class DocumentSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :modify_frag_size, :modify_fl ]
  include BlacklightRangeLimit::RangeLimitBuilder

  def modify_frag_size(solr_parameters)
    solr_parameters[:"hl.fragsize"] = 0
  end

  def modify_fl(solr_parameters)
    solr_parameters[:fl] = '*'
  end
end
