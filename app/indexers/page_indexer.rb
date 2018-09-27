require 'net/http'

class PageIndexer

  attr_accessor :page

  def initialize(page)
    @page = page
    @repository_service = RepositoryService.new(nil)
  end

  def generate_solr_doc(issue_doc)

    full_text = get_full_text(@page.page_identifier, @page.text_link)

    solr_doc = { 
      id: @page.page_identifier, # "#{issue_doc[:volume_identifier]}-#{volume_sequence}",
      page_number_t:@page.page_number, 
      issue_sequence: @page.issue_sequence,
      volume_sequence: @page.volume_sequence,
      page_identifier: @page.page_identifier,
      issue_identifier: issue_doc[:issue_identifier],
      page_label: @page.page_label,
      text_link: @page.text_link, 
      image_link: @page.image_link,
      coordinates_link: @page.coordinates_link,
      page_text:full_text,
      image_height_ti: @page.height,
      image_width_ti: @page.width,
      prev_page_link: nil,
      next_page_link: nil,
      next_page_sequence_label: nil,
      prev_page_sequence_label: nil,
      next_page_label: nil,
      prev_page_label: nil
    }

    [ :date_issued_display, 
      :issue_number_t,
      :variant_sequence,
      :date_issued_dt, 
      :issue_id_t, 
      :issue_vol_iss_display,
      :date_issued_yyyy_ti,
      :date_issued_yyyymm_ti,
      :date_issued_yyyymmdd_ti,
      :date_issued_yyyy10_ti,
      :date_issued_mm_ti,
      :date_issued_dd_ti,
      :date_issued_link,
      :volume_identifier,
      :publication_link,
      :publication_label
    ].each do |key|
      solr_doc[key] = issue_doc[key]
    end

    current_index = issue_doc[:pages].index { |v| v[0] == @page.id }
    unless current_index - 1 < 0
      solr_doc[:prev_page_link] = issue_doc[:pages][current_index - 1][1]
      solr_doc[:prev_page_sequence_label] = issue_doc[:pages][current_index - 1][2]
      solr_doc[:prev_page_label] = issue_doc[:pages][current_index - 1][3]
    end
    if current_index + 1 <= ( issue_doc[:pages].size - 1 )
      solr_doc[:next_page_link] = issue_doc[:pages][current_index + 1][1]
      solr_doc[:next_page_sequence_label] = issue_doc[:pages][current_index + 1][2]
      solr_doc[:next_page_label] = issue_doc[:pages][current_index + 1][3]
    end

    solr_doc
  end

  def index(issue_doc)
    solr_doc = generate_solr_doc(issue_doc)
    conn = Blacklight.default_index.connection
    conn.add solr_doc
  end

  def get_full_text(page_identifier, text_link)
    return "" unless text_link

    if ENV['USE_FILESYSTEM']
      # this is the text_link - bhl_midaily:mdp.39015071730621-00000003:TXT00000003
      resource_filename = @repository_service.dlxs_filename(text_link)
      response = Zlib::GzipReader.open(resource_filename) { |f| f.read }

    else
      # HTTP request
      resource_url = @repository_service.dlxs_file_url(text_link)
      resource_uri = URI.parse(resource_url)

      http = Net::HTTP.new(resource_uri.host, resource_uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(resource_uri.request_uri)
      response = http.request(request)

      # response = Net::HTTP.request_get(resource_uri)
      unless response.is_a?(Net::HTTPSuccess)
        # STDERR.puts "#{resource_uri} : #{response.code}"
        response = ""
      else
        # STDERR.puts ":: #{response.body.encoding} :: #{response.type_params}"
        response = response.body.force_encoding('UTF-8') # .encode('UTF-8', invalid: :replace, undef: :replace)
        # STDERR.puts ":: >> #{response.encoding}"
      end

    end

    response
  end


end