# frozen_string_literal: true
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_search_to_page_title(params)
    constraints = []

    if params['q'].present?
      q_label = label_for_search_field(params[:search_field]) unless blacklight_config.default_search_field && params[:search_field] == blacklight_config.default_search_field[:key]

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
    retval
  end
end
