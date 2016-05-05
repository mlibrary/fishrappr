module Fishrappr
  class SearchState < Blacklight::SearchState

    def url_for_document(doc, options = {})
      if doc and respond_to?(:blacklight_config) and
          blacklight_config.show.route and
          (!doc.respond_to?(:to_model) or doc.to_model.is_a? SolrDocument)
        # route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
        route = blacklight_config.show.route.merge(issue_date: doc.fetch('issue_date_dt').split('T')[0], sequence: doc.fetch('sequence_i')).merge(options)
        route.delete(:id)
        route[:controller] = params[:controller] if route[:controller] == :current
        route
      else
        doc
      end
    end



  end
end
