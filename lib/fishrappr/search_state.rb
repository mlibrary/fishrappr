module Fishrappr
  class SearchState < Blacklight::SearchState

    # force hierachical URLs for SolrDocument
    def url_for_document(doc, options = {})
      if doc and respond_to?(:blacklight_config) and
          blacklight_config.show.route and
          (!doc.respond_to?(:to_model) or doc.to_model.is_a? SolrDocument)
        route = blacklight_config.show.route.merge(
          action: :show, 
          publication: doc.fetch('publication_link'),
          volume_identifier: doc.fetch('volume_identifier'),
          volume_sequence: doc.fetch('volume_sequence')
        ).merge(options)
        route.delete(:id)
        route[:controller] = params[:controller] if route[:controller] == :current
        route
      else
        doc
      end
    end

  end
end
