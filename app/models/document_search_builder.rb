class DocumentSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :modify_frag_size, :modify_fl, :filter_by_page_identifier ]

  def modify_frag_size(solr_parameters)
    solr_parameters[:"hl.fragsize"] = 0
  end

  def modify_fl(solr_parameters)
    solr_parameters[:fl] = '*'
  end

  def filter_by_page_identifier(solr_parameters)
    solr_parameters[:fq] ||= []
    page_identifier = blacklight_params[:page_identifier]
    if page_identifier
      solr_parameters[:fq] << "{!term f=id}#{page_identifier}"
    end
  end

end
