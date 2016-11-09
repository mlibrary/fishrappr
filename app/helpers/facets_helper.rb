# frozen_string_literal: true
module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  ##
  # 9-12-16 GML Per Colin C made sr-only text more specific
  # Standard display of a SELECTED facet value (e.g. without a link and with a remove button)
  # @params (see #render_facet_value)
  def render_selected_facet_value(facet_field, item)
    sr_only_str = String.new("remove facet limit ")
    sr_only_str << facet_display_value(facet_field, item)
    remove_href = search_action_path(search_state.remove_facet_params(facet_field, item))
    content_tag(:span, class: "facet-label") do
      content_tag(:span, facet_display_value(facet_field, item), class: "selected") +
      # remove link
      link_to(remove_href, class: "remove") do
        content_tag(:span, '', class: "fa fa-close") +
        content_tag(:span, sr_only_str, class: 'sr-only')
      end
    end + render_facet_count(item.hits, :classes => ["selected"])
  end

  ##
  # 9-12-16 GML Per Colin C added title facet count span 
  # Renders a count value for facet limits. Can be over-ridden locally
  # to change style. And can be called by plugins to get consistent display. 
  #
  # @param [Integer] number of facet results
  # @param [Hash] options
  # @option options [Array<String>]  an array of classes to add to count span.
  # @return [String]
  def render_facet_count(num, options = {})
    classes = (options[:classes] || []) << "facet-count"
    content_tag("span", t('blacklight.search.facets.count', :number => number_with_delimiter(num)), :title=> 'Number of records', :class => classes)
  end

  # facet_field_label
  # Render a label/value constraint on the screen. Can be called
  # by plugins and such to get application-defined rendering.
  #
  # Can be over-ridden locally to render differently if desired,
  # although in most cases you can just change CSS instead.
  #
  # Can pass in nil label if desired.
  #
  # @param [String] label to display
  # @param [String] value to display
  # @param [Hash] options
  # @option options [String] :remove url to execute for a 'remove' action
  # @option options [Array<String>] :classes an array of classes to add to container span for constraint.
  # @return [String]
  def render_constraint_element(label, value, options = {})
    ### save this in case we need an abbreviated label
    # label = 'On' if label == 'On Page'
    render(:partial => "catalog/constraints_element", :locals => {:label => label, :value => value, :options => options})
  end
end