require 'net/http'

class PageIndexer

  attr_accessor :page

  def initialize(page)
    @page = page
  end

  def generate_solr_doc(issue_doc)

    full_text = get_full_text(@page.page_identifier, @page.text_link)
    # coordinates_data = get_coordinates_data(issue_doc, @page.coordinates_link)

    # page_identifier = "#{issue_doc[:ht_namespace]}.#{issue_doc[:ht_barcode]}-#{volume_sequence}"

    image_info = get_image_info_from_manifest(issue_doc[:manifest], @page.image_link)

    solr_doc = { 
      id: @page.page_identifier, # "#{issue_doc[:volume_identifier]}-#{volume_sequence}",
      page_no_t:@page.page_no, 
      issue_sequence: @page.issue_sequence,
      volume_sequence: @page.volume_sequence,
      page_identifier: @page.page_identifier,
      issue_identifier: issue_doc[:issue_identifier],
      page_label: @page.page_label,
      text_link: @page.text_link, 
      image_link: @page.image_link, 
      coordinates_link: @page.coordinates_link,
      page_text:full_text,
      image_height_ti: image_info.fetch("height", nil),
      image_width_ti: image_info.fetch("width", nil),
      prev_page_link: nil,
      next_page_link: nil,
      next_page_sequence_label: nil,
      prev_page_sequence_label: nil,
      next_page_label: nil,
      prev_page_label: nil
    }

    STDERR.puts "??? #{solr_doc[:id]} :: #{solr_doc[:page_label]}"

    [ :date_issued_display, 
      :issue_no_t,
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

  def get_data(issue_doc, link, ext)
    return nil if link.nil?
    filename = Rails.root.join(
      Rails.configuration.sdrdataroot, 
      "#{issue_doc[:ht_namespace]}/#{issue_doc[:ht_barcode]}", 
      link+ext)
    if File.exists?(filename)
      File.read(filename)
    else
      nil
    end
  end

  def get_full_text(page_identifier, text_link)
    # File.read(Rails.root.join(
    #   Rails.configuration.sdrdataroot, 
    #   "#{issue_doc[:ht_namespace]}/#{issue_doc[:ht_barcode]}", 
    #   text_link+'.txt'))
    ## get_data(issue_doc, text_link.gsub('TXT', ''), ".txt")
    resource_uri = "#{Rails.configuration.media_service}file/#{Rails.configuration.media_collection}:#{page_identifier}:#{text_link}"
    STDERR.puts "== #{resource_uri}"
    resource_uri = URI.parse(resource_uri)

    http = Net::HTTP.new(resource_uri.host, resource_uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(resource_uri.request_uri)
    PP.pp http, STDERR
    PP.pp request, STDERR
    response = http.request(request)

    # response = Net::HTTP.request_get(resource_uri)
    PP.pp response, STDERR
    unless response.is_a?(Net::HTTPSuccess)
      STDERR.puts "#{resource_uri} : #{response.code}"
      response = ""
    else
      response = response.body
    end
    response
  end

  def get_coordinates_data(issue_doc, coordinates_link)
    return get_data(issue_doc, coordinates_link.gsub('WORDS', ''), ".js")
  end

  def get_image_info_from_manifest(manifest, img_link)
    if manifest[img_link].nil?
      STDERR.puts "DID NOT FIND: #{img_link}"
    end
    manifest[img_link]
  end

  def get_image_info(page_identifier, img_link)
    # image_href = "https://beta-3.babel.hathitrust.org/cgi/imgsrv/iiif/#{issue_doc[:ht_namespace]}.#{issue_doc[:ht_barcode]}/#{img_link}/info.json"
    # return {} if ( img_link.nil? || issue_doc[:manifest].nil? )
    # key = "#{issue_doc[:ht_barcode]}/#{img_link}"
    # issue_doc[:manifest][key]

    info_href = "#{Rails.configuration.iiif_service}#{Rails.configuration.media_collection}:#{page_identifier}:#{img_link}/info.json"
    STDERR.puts info_href
    image_uri = URI(info_href)
    response = Net::HTTP.get(image_uri)
    JSON.parse(response)

  end

end