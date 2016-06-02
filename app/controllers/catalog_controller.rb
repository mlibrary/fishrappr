# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller

  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Catalog
  include Fishrappr::Catalog

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    #config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    config.document_presenter_class = Fishrappr::DocumentPresenter

    # Add actions for splash, about, and donors pages
    config.add_nav_action(:about, partial: 'shared/nav/about')
    config.add_nav_action(:help, partial: 'shared/nav/help')
    config.add_nav_action(:contact, partial: 'shared/nav/contact')

    config.navbar.partials.delete(:bookmark)
    config.navbar.partials.delete(:saved_searches)
    config.navbar.partials.delete(:search_history)
    config.navbar.partials.delete(:login)

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 24,
      :qt => 'search',
      :qf => 'page_text',
      :hl => true,
      :"hl.fragsize" => 200,
      :"hl.fl" => 'page_text',
      :"hl.snippets" => 10,
      :"hl.alternateField" => 'page_text',
      :"hl.simple.pre" => '<span class="highlight">',   # change to something accessible
      :"hl.simple.post" => '</span>', # change to something accessible
      fl: '*'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]
    config.per_page = [ 24, 48, 144 ]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
     qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
     fl: '*',
     rows: 1,
     q: '{!term f=id v=$id}'
    }

    config.document_index_view_types = ["default", "gallery", "list", "frequency", "covers"]
    config.view.grid.partials = [:index]
    config.view.grid.icon_class = "glyphicon-th-large"

    # solr field configuration for search results/index views
     config.index.title_field = 'date_issued_display'
#    config.index.page_no_field = 'page_no_t'

    # solr field configuration for document/show views
     config.show.title_field = 'date_issued_display'
#    config.show.date_issued_field = 'date_issued_t'
#    config.index.page_no_field = 'page_no_t'


    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'date_issued_dt', label: 'Issue Date', helper_method: :render_date_format
    config.add_facet_field 'issue_no_t', label: 'Issue No'
    config.add_facet_field 'date_issued_yyyy_ti', label: 'Issue Year', range: true
    config.add_facet_field 'date_issued_yyyymmdd_ti', label: 'Date Range', range: {
                         num_segments: 6,
                         maxlength: 8
                       }

    #config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['format', 'language_facet']

    #config.add_facet_field 'example_query_facet_field', label: 'Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    #}


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    #config.add_index_field 'date_issued_dt', label: 'Issue Date'
    config.add_index_field 'issue_no_t', label: 'Issue'
    config.add_index_field 'page_no_t', label: 'Page No'
    config.add_index_field 'sequence', label: 'Page Order'
    config.add_index_field 'page_text', label: 'Page Text' , highlight: true, separator_options: { words_connector: ' ... '}

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'issue_no_t', label: 'Issue'
    config.add_show_field 'date_issued_display', label: 'Date'
    config.add_show_field 'page_no_t', label: 'Page No'
    config.add_show_field 'sequence', label: 'Page Order'
    config.add_show_field 'page_text', label: 'Page Text'

    config.add_show_field 'next_page_link', label: 'Next Page Link'
    config.add_show_field 'next_page_label', label: 'Next Page Label'
    config.add_show_field 'prev_page_link', label: 'Previous Page Link'
    config.add_show_field 'prev_page_label', label: 'Previous Page Label'

    #config.add_show_field 'img_link_t', label: 'Image', helper_method: :hathitrust_image_src(document)

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    config.add_search_field 'page_text' do |field|
      field.include_in_simple_select = false
      advanced_parse = true
      field.solr_parameters = { :qf => "page_text" } 
    end

    config.add_search_field 'ht_barcode' do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { :qf => "ht_barcode" } 
    end


    #config.add_search_field 'OCR Text' do |field|
     #field.solr_parameters = { qf: 'page_text' , hl: true}
     #advanced_parse = true
    #end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    #config.add_search_field('page_text') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
    #field.solr_parameters = { :'spellcheck.dictionary' => 'page_no' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
     #field.solr_local_parameters = {
      # qf: '$full_text_qf',
      # pf: '$full_text_pf'
      #}
    #end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'date_issued_dt desc', label: 'Latest Date'
    config.add_sort_field 'date_issued_dt asc', label: 'Earliest Date'
    config.add_sort_field 'date_issued_dt desc, issue_no_t_sort asc', label: 'Page Number'
    #config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    #config.add_sort_field 'title_sort asc, pub_date_sort desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'

    config.show.route = { controller: 'catalog', action: 'show' }
    # binding.pry
  end
end
