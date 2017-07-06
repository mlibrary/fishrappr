class DocumentSearchBuilder < Blacklight::SearchBuilder
  attr_accessor :use_page_text_for_alt_highlight
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :modify_frag_size, :modify_fl, :modify_hl, :filter_by_page_identifier ]

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

  def modify_hl(solr_parameters)
    if use_page_text_for_alt_highlight
      solr_parameters[:"hl.alternateField"] = 'page_text'
    end
  end

end
