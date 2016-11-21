require 'digest'
module ApplicationHelper

  def publication_root_url
    if @publication
      publication_home_url(@publication.slug)
    else
      root_url
    end
  end

  def toggle_highlight_solr_document_path(document)
    _build_document_url(document, { action: :toggle_highlight })
  end

  def download_text_solr_document_path(document)
    _build_document_url(document, { action: :download_text })
  end

  def download_issue_text_solr_document_path(document)
    _build_document_url(document, { action: :download_issue_text })
  end

  def issue_data_solr_document_path(document)
    _build_document_url(document, { action: :issue_data })
  end

  def solr_document_path(document, options)
    _build_document_url(document, options)
  end

  def solr_document_url(document, options = {})
    _build_document_url(document, options.merge(only_path: false))
  end

  def _build_document_url(document, options)
    url_for url_for_document(@document, options)
  end

  ##
  # Link to the previous document in the current search context
  def link_to_previous_issue_page(previous_document)
    link_opts = { class: 'btn btn-page-navigation' }
    link_to_unless previous_document.nil?, use_icon('previous') + " " + raw(t('views.issue.previous')), url_for_document(previous_document), link_opts do
      content_tag :span, use_icon('previous') + " " + raw(t('views.issue.previous')), :class => 'btn btn-page-navigation endpoint'
    end
  end

  ##
  # Link to the next document in the current search context
  def link_to_next_issue_page(next_document)
    link_opts = { class: 'btn btn-page-navigation' }
    link_to_unless next_document.nil?, raw(t('views.issue.next')) + " " + use_icon('next'), url_for_document(next_document), link_opts do
      content_tag :span, raw(t('views.issue.next')) + " " + use_icon('next'), :class => 'btn btn-page-navigation endpoint'
    end
  end

  def current_page_number(document)
    page_number = document.fetch('page_no_t', []).first
    unless page_number
      page_number = "(seq #{document.fetch('issue_sequence')})"
    end
    page_number
  end

  def current_image_sequence(document)
    document.fetch('issue_sequence')
  end

  def issue_title(document, complete=false)
    title = document['date_issued_display'].first
    if complete
      title += "<span class='hidden-xs'> " + issue_subtitle(document) + '</span>'
    end
    title.html_safe
  end

  def issue_subtitle(document)
    document.fetch(:issue_vol_iss_display, []).first.gsub(/, ed\. \d+/, '')
  end

  def document_to_date_params(document)
    params = {}

    params[:search_field] = 'all_fields'
    params[:date_filter] = 'on'
    params[:date_issued_begin_dd] = document.fetch(:date_issued_dd_ti)
    params[:date_issued_begin_mm] = document.fetch(:date_issued_mm_ti)
    params[:date_issued_begin_yyyy] = document.fetch(:date_issued_yyyy_ti)
    params[:sort] = 'score desc, date_issued_dt desc, issue_no_t_sort asc, issue_sequence asc' # relevance
    params
  end

  def download_pdf_link(document, fld, **kw)
    rgn1 = ( fld == 'page_identifier' ) ? 'ic_id' : fld
    value = document.fetch(fld)
    RepositoryService.download_pdf_url(rgn1, value)
  end

  def document_image_src(document, **kw)
    path_info = []
    namespace = document.fetch('volume_identifier').split('.').first

    if namespace == 'fake'
      return '#'
    end

    RepositoryService.dlxs_image_url(document, **kw)
  end

  def document_thumbnail_src(document, **kw)
    size = kw.fetch(:size, ',250')
    document_image_src(document, size: size)
  end

  def document_thumbnail_style(document, **kw)
    namespace = document.fetch('volume_identifier').split('.').first

    if namespace == 'fake'
      image_height = 1600
      image_width = 1185
    else
      image_height = document.fetch('image_height_ti')
      image_width = document.fetch('image_width_ti')
    end
    size = kw.fetch(:size, ',250')
    width, height = size.split(',')
    if not width.blank?
      width = width.to_i
      height = ( image_height * ( width.to_f / image_width ) ).to_i
    else
      height = height.to_i
      width = ( image_width * ( height.to_f / image_height ) ).to_i
    end

    # { 'min-width' => width, 'min-height' => height }
    "min-width: #{width}px; min-height: #{height}px"

  end

  def document_thumbnail_data(document, **kw)
    namespace = document.fetch('volume_identifier').split('.').first

    if namespace == 'fake'
      image_height = 1600
      image_width = 1185
    else
      image_height = document.fetch('image_height_ti')
      image_width = document.fetch('image_width_ti')
    end
    size = kw.fetch(:size, ',250')
    width, height = size.split(',')
    if not width.blank?
      width = width.to_i
      height = ( image_height * ( width.to_f / image_width ) ).to_i
    else
      height = height.to_i
      width = ( image_width * ( height.to_f / image_height ) ).ceil
    end

    { :'data-min-width' => width, :'data-min-height' => height }
  end

  def document_image(document, **kw)
    namespace = document.fetch('volume_identifier').split('.').first
    return fake_image(document).html_safe if namespace == 'fake'
    %Q{<img src="#{document_image_src(document, **kw)}" tabindex="-1", aria-hidden="true", alt="Full image of Daily page" />}.html_safe
  end

  def document_thumbnail(document, **kw)
    namespace = document.fetch('volume_identifier').split('.').first
    return fake_image(document, kw.fetch(:size, ',250')) if namespace == 'fake'
    alt_text = "image of #{document['date_issued_display'].first} - number #{document.fetch('issue_sequence')}"
    %Q{<img src="#{document_thumbnail_src(document, **kw)}" tabindex="-1", aria-hidden="true", alt="#{alt_text}" />}.html_safe
  end

  # TO DO: Needs to be moved into a style using a data attribute
  def document_background_thumbnail(document, **kw)
    namespace = document.fetch('volume_identifier').split('.').first
    tn = "style=\'background: url(\""
    if namespace == 'fake'
      tn += "#{image_url("fake_image.png")}"
    else
      tn += "#{document_thumbnail_src(document, **kw)}"
    end
    tn += "\") top left no-repeat;\'"
    tn.html_safe
  end

  def iiif_identifier(document, fld='image_link')
    RepositoryService.dlxs_identifier(document, fld)
  end

  def link_to_repository(document=nil)
    html = %Q{<link rel="repository" href="#{RepositoryService.dlxs_repository_url}" />}
    html.html_safe
  end

  def link_to_manifest(document)
    %Q{<link rel="manifest" href="#{RepositoryService.dlxs_manifest_url(document)}" />}.html_safe
  end

  def render_date_format(args)
    args.to_date.strftime("%B %d, %Y")
  end  

  def highlight_search_terms(full_text)
    search_params = current_search_session.try(:query_params) 
    search_field = search_params["q"] 
    if search_field
      highlighted_field = '<strong>'+ search_field + '</strong>'.html_safe 
      @document["page_text"].first.gsub! search_field,highlighted_field 
    end
    return @document["page_text"].first 
  end

  def render_plain_text(document, field, breaks: true, truncate: true)
    retval = []
    texts = nil
    search_params = current_search_session.try(:query_params) 
    search_field = search_params ? search_params["q"] : nil
    if document.has_highlight_field?(field)
      texts = document.highlight_field(field)
      if search_field.blank?
        texts.collect!{|text| text.truncate(750) if truncate}
      end
    elsif breaks and document.fetch('page_text', nil)
      texts = document.fetch(field)
    else
      texts = document.fetch('page_abstract', 'WUT')
    end
    prefix = breaks ? '' : '&#8230;'.html_safe
    retval = ActiveSupport::SafeBuffer.new
    counter = Hash.new(0)
    seen = Hash.new(0)
    Array(texts).each do |text|
      next if text.strip.blank?
      text = text.truncate(450) if truncate # less jiggering in results view

      text.scan(/\[\[\[([^\]]+)\]\]\]/).each do |match|
        counter[match.first.downcase] += 1
      end

      do_skip = counter.each.collect { |match, value| value > 2 && seen[match] > 0 }.index(true)
      # do_skip = false if params[:noskip]
      next if do_skip

      counter.keys.each { |key| seen[key] += 1 }

      retval << '<p>'.html_safe
      retval << prefix + text + prefix # .gsub("\n", " ")
      retval << '</p>'.html_safe
    end
    retval.gsub!(/\n\n+/, "\n\n")
    retval.gsub!(/\n/, breaks ? "<br />\n".html_safe : " ")
    (retval.gsub('[[[[', '<span class="highlight">'.html_safe).gsub(']]]]', '</span>'.html_safe)).html_safe
  end

  NON_LEXEMES = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")
  def cleanup_word(text)
    text.gsub(NON_LEXEMES, '').strip
  end

  def blank_identifier(*args)
    "_:N" + hash_words(*args)
  end

  def hash_words(*args)
    Digest::MD5.hexdigest args.join('')
  end

  require 'ffaker'
  def fake_image(document, size=nil)
    namespace = document.fetch('volume_identifier').split('.').first
    barcode = document.fetch('volume_identifier').split('.').last
    text_link = document.fetch('text_link')
    issue_no = document.fetch("issue_no_t", ['-']).first
    page_sequence = document.fetch("issue_sequence")
    key = namespace + "." + barcode + "/" + text_link
    bgcolor = Rails.cache.fetch("#{namespace}.#{barcode}/bgcolor") do
      # [ 'sky', 'vine', 'lava', 'gray', 'industrial', 'social' ].sample
      "#%06x" % rand(0..0xffffff)
    end
    text = "#{issue_no} / #{page_sequence}"
    if size == ',150'
      return holder_tag "110x150", text, nil, {}, { bg: bgcolor }
    elsif size == ",250"
      return holder_tag "187x250", text, nil, {}, { bg: bgcolor }
    elsif size == '200,'
      return holder_tag "200x270", text, nil, {}, { bg: bgcolor }
    else
      # text = Rails.cache.fetch(key) do
      #   FFaker::CheesyLingo.sentence
      # end
      return holder_tag "375x500", text, nil, {}, { bg: bgcolor }
    end
  end

  def back_to_results_label
    search_params = current_search_session.try(:query_params) || {}
    return if search_params.blank?
    if search_params[:action] == 'browse'
      use_icon('previous') + " " + t('blacklight.back_to_browse_html')
    else
      use_icon("previous") + " " + t('blacklight.back_to_search_html')
    end
  end

  # SEARCH SELECT OPTIONS  
  # See blacklight_range_limit/app/helpers/range_limit_helper.rb, use date_issued_yyy_ti
  # Used by date search box
  def get_solr_years_options
    min_year = range_results_endpoint("date_issued_yyyy_ti", 'min')
    max_year = range_results_endpoint("date_issued_yyyy_ti", 'max')
    if (!min_year.nil? && !max_year.nil?)
      years_range = (min_year..max_year) 
    else
      years_range = (1890..1970)
    end
    years_options = [];
    years_range.each do |y| 
      item = [y, y]
      years_options.push item
    end
    years_options
  end

  # Used by date search box
  def get_month_options
    month_options = (1..12).collect do |mm|
      [ Date::MONTHNAMES[mm], mm ]
    end
    month_options
  end

  # Used by date search box
  def get_date_options
    date_range = (1..31)
    date_options = [];
    date_range.each do |d| 
      item = [d, d]
      date_options.push item
    end
    date_options
  end  
  
  # BROWSE OPTIONS  

  # Used by browse page
  def get_decade_browse_options
    decades = [1890, 1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010]
    decade_options = [];

    item = ["Any Decade", "Any Decade"]
    decade_options.push item

    decades.each do |decade|
      decade_options.push([ decade.to_s + "'s", decade ])
    end
    decade_options
  end

  # Used by browse page as initial year options; see js for how this changes for different decades
  def get_year_browse_options
    years_range = (1890..2016)
    year_options = [];

    years_range.each do |m| 
      item = [m, m]
      year_options.push item
    end
    year_options.reverse!

    item = ["Any Year", "Any Year"]
    year_options.insert(0, item)
  end

  def get_month_label(mm)
    begin
      Date::MONTHNAMES[mm.to_i]
    rescue
      mm
    end
  end

  # GRAPH CODE

  ##
  # Support for facet-drive result data graph
  # Return raw facet values with facet name
  # Assumes Decade, Year, Month, and Day facets available
  # Returns a hash in incorporate into the search_graph partial
  # for use with sidebar_graph.js
  # example &amp;f%5Bdate_issued_yyyy10_ti%5D%5B%5D=1950
  # &f[date_issued_yyyy10_ti][]=1950
  def get_graph_data(params)
    # get facet data
    facet_data = date_facet_data_to_hash

    # get the key and value to use for the date graph
    facet_key, facet_val = get_smallest_date_filter(params)

    # get data to display in an array
    display_info = get_display_info(facet_data, facet_key, facet_val)

    display_info
  end

  ##
  # Turns the facet data into values for hidden fields in chart
  # Returns an hash of title, highest # of matching pages, lowest # of matching pages,
  # and column name and values strings of chart data
  def get_display_info(data, key, val)

    rtn = {}
    rtn['status'] = "good"

    case key
    when nil # display all decades
      items = data['date_issued_yyyy10_ti']["items"]
      bl_items = data['date_issued_yyyy10_ti']["bl_items"]
      this_range = (189..201).map { |d| d * 10}
      rtn['chart_title'] = "Decades"
      rtn['facet_key'] = 'date_issued_yyyy10_ti'

    when 'date_issued_yyyy10_ti' # display years in one decade
      items = data['date_issued_yyyy_ti']["items"]
      bl_items = data['date_issued_yyyy_ti']["bl_items"]
     #val is the start of the range
      this_range = (val..(val + 9))        
      rtn['chart_title'] = "Years in the #{val}s"
      rtn['facet_key'] = 'date_issued_yyyy_ti'

    when 'date_issued_yyyy_ti' # display months in one year
      items = data['date_issued_mm_ti']["items"]
      bl_items = data['date_issued_mm_ti']["bl_items"]
      this_range = (1..12)
      rtn['chart_title'] = "Months in #{val}"
      rtn['facet_key'] = 'date_issued_mm_ti'

    when "date_issued_mm_ti"
      items = data['date_issued_dd_ti']["items"]
      bl_items = data['date_issued_dd_ti']["bl_items"]
      rtn['chart_title'] = "Days in Month #{Date::MONTHNAMES[val]}"
      rtn['facet_key'] = 'date_issued_dd_ti'

      case val
      when 2
        end_date = 29 # assumes some leap years may be included
      when 4, 6, 9, 11
        end_date = 30
      else
        end_date = 31
      end

      this_range = (1..end_date)

    when 'date_issued_dd_ti' # display months in one year
      items = data['date_issued_dd_ti']["items"]
      bl_items = data['date_issued_dd_ti']["bl_items"]
      rtn['chart_title'] = "Day #{val}"
      rtn['facet_key'] = 'date_issued_dd_ti'

      # we don't know what months may be includes so use widest range.
      this_range = (1..31) 

    else
      rtn['chart_title'] = "Graph data not available."
      rtn['status'] = "bad"
    end # case  when "date_issued_mm_ti"

    if (rtn['status'] == "good")

      # Code common to all cases
      return_items = {}
      rtn['highest_col'] = items.values.max
      rtn['lowest_col'] = items.values.min
      rtn['js_names_str'] = ""
      rtn['js_values_str'] = ""
      rtn['js_links_str'] = ""

      this_range.each do |d|
        # if we have data use it otherwise set item to zero
        # note that data keys are strings but new keys are ints
        if ( items.key?(d.to_s) )
          return_items[d] = items[d.to_s]
        else
          return_items[d] = 0
        end

        # bar names
        rtn['js_names_str'] += "#{d}"
        # bar values
        rtn['js_values_str'] += "#{return_items[d]}"

        # bar links
        if ( bl_items.key?(d.to_s) ) # && rtn['facet_key'] != 'date_issued_dd_ti' )
          path = path_for_facet(rtn['facet_key'], bl_items[d.to_s])
          rtn['js_links_str'] += path
        else
          rtn['js_links_str'] += "#"
        end

        if ( d != this_range.last )
          rtn['js_values_str'] += ", "
          rtn['js_names_str'] += ", "
          rtn['js_links_str'] += ", "
        end 

      end # each
    end # if rtn['status'] == "good"

    rtn
  end

  ##
  # Collect the chunked date facet data into a hash
  # from facets_from_request
  # Returns a hash with the facet name as a key
  def date_facet_data_to_hash
    gfacets = facets_from_request
    rtn = {}
    gfacets.each do |f| 

      rtn[f.name] = {}

      case f.name
      when "date_issued_yyyy10_ti"
        rtn[f.name]["label"] = "Decades"
      when "date_issued_yyyy_ti"
        rtn[f.name]["label"] = "Years"
      when "date_issued_mm_ti"
        rtn[f.name]["label"] = "Months"
      when "date_issued_dd_ti"
        rtn[f.name]["label"] = "Days"
      else
      end

      unless (f.name == "date_issued_yyyymmdd_ti")

        rtn[f.name]["name"] = f.name

        rtn[f.name]["items"] = {}
        rtn[f.name]["bl_items"] = {}

        if ( !f.items.empty? )
          f.items.each do |i|
            rtn[f.name]["bl_items"][i.value] = i
            rtn[f.name]["items"][i.value] = i.hits

          end # f.items.each
        end # if f.items.empty?
      end # unless
    end # gfacets.each

    rtn
  end

  ##
  # Get the scale to use for displaying graph data
  # from param filters
  # Returns the chunked date facet key, e.i., date_issued_yyyy10_ti
  # and its value
  def get_smallest_date_filter(parms)
    if (!parms.key?('f'))
      return nil # show all decades
    else
      filters = parms['f']
    end

    # show one date in month
    return 'date_issued_dd_ti', filters['date_issued_dd_ti'].first.to_i if (filters.key?('date_issued_dd_ti'))    

    # show dates in month
    return 'date_issued_mm_ti', filters['date_issued_mm_ti'].first.to_i if (filters.key?('date_issued_mm_ti'))

    # show months in year
    return 'date_issued_yyyy_ti', filters['date_issued_yyyy_ti'].first.to_i if (filters.key?('date_issued_yyyy_ti'))

    # show years in decade
    return 'date_issued_yyyy10_ti', filters['date_issued_yyyy10_ti'].first.to_i if (filters.key?('date_issued_yyyy10_ti'))

    # show all decades
    return nil
  end

  def active_date_facets?(prms)

    if (!prms.key?('f'))
      return false # show all decades
    else
      filters = prms['f']
    end

    # show one date in month
    return true if (filters.key?('date_issued_dd_ti'))    

    # show dates in month
    return true if (filters.key?('date_issued_mm_ti'))

    # show months in year
    return true if (filters.key?('date_issued_yyyy_ti'))

    # show years in decade
    return true if (filters.key?('date_issued_yyyy10_ti'))

    false

  end
  
end
