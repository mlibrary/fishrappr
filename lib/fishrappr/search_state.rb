module Fishrappr
  class SearchState < Blacklight::SearchState

    # def url_for_document(doc, options = {})
    #   if doc and respond_to?(:blacklight_config) and
    #       blacklight_config.show.route and
    #       (!doc.respond_to?(:to_model) or doc.to_model.is_a? SolrDocument)
    #     # route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
    #     route = blacklight_config.show.route.merge(
    #       publication_link: doc.fetch('publication_link'),
    #       ht_barcode: doc.fetch('ht_barcode'),
    #       date_issued_link: doc.fetch('date_issued_link'),
    #       sequence: doc.fetch('sequence')
    #       ).merge(options)
    #     route.delete(:id)
    #     route[:controller] = params[:controller] if route[:controller] == :current
    #     route
    #   else
    #     doc
    #   end
    # end



  end
end
