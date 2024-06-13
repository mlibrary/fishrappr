# require 'iiif/presentation'
# require 'iiif/service'
require 'pp'
require 'net/http'

module IIIF

  class Nop
    attr_accessor :data
    def initialize(data)
      @data = data
    end

    def collections
      @data['collections']
    end

    def sequences
      @data['sequences']
    end

    def metadata
      @data['metadata']
    end

    def manifests
      @data['manifests']
    end

    def see_also
      @data['seeAlso']
    end

    def images
      @data['images']
    end

    def height
      @data['height']
    end

    def width
      @data['width']
    end
  end

  class Service
    attr_accessor :data, :response
    def self.parse(response)
      @response = response
      ob = Nop.new(JSON.parse(response))
    rescue Exception => e
      STDERR.puts "JSON PARSE ERROR: #{e}"
      STDERR.puts "[#{@response}]"
      raise
    end
  end
end

class DlxsIngest

  attr_accessor :clobber

  def initialize(publication_slug, collid)
    @publication = Publication.find_by_slug(publication_slug)
    @collid = collid
    @repository_service = RepositoryService.new(nil)
  end

  def fetch_volumes()
    collection_url = @repository_service.dlxs_collection_url(@collid)
    response = fetch_data(collection_url)
    collection = IIIF::Service.parse(response)
    t0 = Time.now
    tdelta = t0
    total = collection.collections.size
    collection.collections.each_with_index do |member, member_idx|
      check = fetch_volume(member['@id'])
      STDERR.puts "-- #{Time.now - tdelta} : #{member_idx} / #{total} : #{member['@id']}"
      tdelta = Time.now
      # unless check == false
      #   delay = rand() * 10
      #   sleep(delay)
      # end
    end
    STDERR.puts "-- #{Time.now - t0} : EOT"
  end

  def fetch_volume(volume_identifier)
    volume_url = service_collection_url(volume_identifier)
    volume_collection = IIIF::Service.parse(fetch_data(volume_url))

    unless @clobber
      check = Issue.where(volume_identifier: local_identifier(volume_identifier)).first
      STDERR.puts "== SKIPPING #{volume_identifier}" unless check.nil?
      return false unless check.nil?
    end

    # delete all the issues because the issue manifests may have changed
    Issue.where(volume_identifier: local_identifier(volume_identifier)).destroy_all

    total = volume_collection.manifests.length
    volume_collection.manifests.each_with_index do |member, idx|
      fetch_issue(member['@id'], idx, total)
      # delay = rand() * 5
      # sleep(delay)
    end
  end

  def fetch_issue(issue_identifier, idx=0, total=0)
    issue_url = service_manifest_url(issue_identifier)
    issue_manifest = IIIF::Service.parse(fetch_data(issue_url))

    build_issue(issue_manifest, idx, total)
  rescue => e
    STDERR.puts "FAILED #{issue_url}"
    STDERR.puts e.class.name
    STDERR.puts e.message
    STDERR.puts e.backgrace
    raise
  end

  def fetch_data(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      STDERR.puts "FAILED: #{response.code}"
      PP.pp response, STDERR
      if response.is_a?(Net::HTTPRedirection) or response.is_a?(Net::HTTPFound)
        STDERR.puts "JUMPING TO #{response['location']}"
      end
      return ''
    end
    response.body
  end

  def service_collection_url(identifier)
    service_url(identifier, :dlxs_collection_url)
  end

  def service_manifest_url(identifier)
    service_url(identifier, :dlxs_manifest_url)
  end

  def service_url(identifier, method)
    unless identifier.start_with?('https://')
      identifier = @repository_service.send(method, identifier)
    end
    identifier # + "?prep=1"
  end

  ##

  def build_issue(manifest, idx=0, total=0)
    metadata = build_metadata(manifest)
    PP.pp metadata, STDERR

    # sigh, delete any previous issues
    # this should be destroy assuming solr wasn't botched up
    Issue.where(issue_identifier: metadata[:issue_identifier]).each do |issue|
      Page.where(issue_id: issue.id).each do |page|
        page.delete
      end
      issue.delete
      STDERR.puts "-- deleted #{issue.id}"
    end

    issue = Issue.create \
      volume_identifier: metadata[:volume_identifier],
      issue_identifier: metadata[:issue_identifier],
      volume: metadata[:issue_volume],
      issue_number: metadata[:issue_number] || 1,
      edition: metadata[:issue_edition],
      date_issued: metadata[:date_issued],
      publication_year: Time.new(metadata[:date_issued]).strftime("%Y"),
      variant_sequence: metadata[:variant_sequence].to_i,
      publication_title: metadata[:publication_title],
      publication: @publication

    t0 = Time.now
    num_processed = 0
    manifest.sequences.each do |sequence|
      sequence['canvases'].each do |canvas|
        # each page is a canvas
        page = build_page(IIIF::Nop.new(canvas), issue)
        num_processed += 1
      end
    end

    STDERR.puts "== #{idx} / #{total} : #{issue.issue_identifier} : #{num_processed} : #{Time.now - t0}"

  end

  def build_page(canvas, issue)
    metadata = build_metadata(canvas)

    # there's a tension between the identifiers-in-IIIF and the local identifiers
    # PP.pp canvas.see_also, STDERR
    text_link = canvas.see_also.select { |h| h['format'] == 'text/plain' }.first
    if text_link
      text_link = File.basename(text_link['@id'])
    end

    coordinates_link = canvas.see_also.select { |h| h['format'] == 'application/json' }.first
    if coordinates_link
      coordinates_link = File.basename(coordinates_link['@id'])
    end


    # image_link = File.basename(canvas.images.first.resource['@id'])
<<<<<<< HEAD
    image_link = File.basename(canvas.images.first['resource']['service']['@id'])
=======
    # image_link = File.basename(canvas.images.first['resource']['@id'])
    image_link = File.basename(canvas.images.first['resource']['service']['@id'])
    STDERR.puts image_link
>>>>>>> 8646ad7 (step 1: docker)
    page = Page.create \
      issue: issue,
      height: canvas.height,
      width: canvas.width,
      text_link: text_link,
      image_link: image_link,
      coordinates_link: coordinates_link,
      issue_sequence: metadata[:issue_sequence].to_i,
      volume_sequence: metadata[:volume_sequence].to_i,
      page_identifier: metadata[:page_identifier],
      page_label: metadata[:page_label].to_s,
      page_number: metadata[:page_number].to_s

  rescue Exception => e
    PP.pp canvas, STDERR
    raise
  end

  def build_metadata(data)
    metadata = {}
    data.metadata.each do |fld|
      metadata[fld['field'].to_sym] = fld['value']
    end
    metadata
  end

  def local_identifier(identifier)
    tmp = File.basename(identifier).split(":")
    return tmp[1] if tmp.size == 3
    tmp[0]
  end

end
