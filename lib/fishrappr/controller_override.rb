module Fishrappr
  module ControllerOverride
    extend ActiveSupport::Concern

    def has_date_filter_parameters?(my_params = params)
      my_params[:date_filter] && my_params[:date_filter] != 'any'
    end

    def has_search_parameters?
      super || has_date_filter_parameters?
    end

    def query_has_constraints?(my_params = params)
      puts "]]]] In query_has_constraints my_params: #{my_params}"
      super || has_date_filter_parameters?(my_params)
    end

    # Over-ride to recognize our custom params for range facets
    def facet_field_in_params?(field_name)
      return super || (
        params["date_filter_options"] && params["date_filter_options"][:fld] == field_name
      )
    end

    def render_constraints_filters(my_params = params)
      content = super(my_params)
      action = case my_params['date_filter']
      when 'any'
        'Any Date'
      when 'before'
        'Before '
      when 'after'
        'After '
      when 'on'
        'On'
      when 'between'
        'Between'
      end

      unless my_params["date_filter_options"].blank?
        solr_field = my_params["date_filter_options"]['begin'][:fld]
        content << render_constraint_element(
          action + " " + facet_field_label(solr_field),
          date_filter_display(solr_field, my_params["date_filter_options"]),
          escape_value: false,
          remove: remove_date_filter_param(solr_field, my_params)
        )
      end
      return content
    end
    
    def date_filter_display(solr_field, hash)

      # hash = my_params[:range][solr_field]

      if hash['begin'] and hash['end']
        return "<span class='from'>#{get_date_filter_value(solr_field, hash['begin'][:value])}</span> to <span class='to'>#{get_date_filter_value(solr_field, hash['end'][:value])}</span>".html_safe
      elsif hash['begin']
        return "<span class='from'>#{get_date_filter_value(solr_field, hash['begin'][:value])}</span>".html_safe
      end
      return ""
      
    end

    def remove_date_filter_param(solr_field, my_params = params)
      if ( my_params["date_filter_options"] )
        my_params = my_params.dup
        my_params.keys.each do |key|
          if key.start_with?('date_filter') or key.start_with?('date_issued_')
            my_params.delete(key)
          end
        end
      end
      return my_params
    end

    def get_date_filter_value(solr_field, value)
      case solr_field
      when 'date_issued_yyyy_ti'
        value
      when 'date_issued_yyyymm_ti'
        DateTime.strptime(value, "%Y%m").strftime("%B %Y")
      when 'date_issued_yyyymmdd_ti'
        DateTime.strptime(value, "%Y%m%d").strftime("%B %d, %Y")
      end
    end

  end
end