module ZzzzzzHelper

  # def presenter(document)
  #   STDERR.puts "AHOY AHOY AHOY #{action_name}"
  #   case action_name
  #   when 'show', 'citation'
  #     show_presenter(document)
  #   when 'index', 'browse'
  #     index_presenter(document)
  #   else
  #     Deprecation.warn(Blacklight::BlacklightHelperBehavior, "Unable to determine presenter type for #{action_name} on #{controller_name}, falling back on deprecated Blacklight::DocumentPresenter")
  #     presenter_class.new(document, self)
  #   end
  # end

  def document_index_view_type query_params=params
    if query_params["action"] == 'browse'
      :grid
    else
      default_document_index_view_type
    end
  end

  def render_search_to_page_title(params)
    constraints = []

    if params['q'].present?
      q_label = label_for_search_field(params[:search_field]) unless default_search_field && params[:search_field] == default_search_field[:key]

      constraints += if q_label.present?
                       [t('blacklight.search.page_title.constraint', label: q_label, value: params['q'])]
                     else
                       [params['q']]
                     end
    end

    if params['f'].present?
      constraints += params['f'].to_unsafe_h.collect { |key, value| render_search_to_page_title_filter(key, value) }
    end

    retval = constraints.join(' / ')
    unless retval.blank?
      retval += " - "
    end
  end
end