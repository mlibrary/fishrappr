require 'pp'
class IssueIndexer

  attr_accessor :issue

  def self.run(ht_namespace, ht_barcode=nil)
    total_issues = Issue.count
    t00 = t0 = Time.now
    query = Issue.where(ht_namespace: ht_namespace)
    if ht_barcode
      query = query.where(ht_barcode: ht_barcode)
    end
    query.each_with_index do |issue, j|
      indexer = self.new(issue)
      indexer.index
      t1 = Time.now
      STDERR.puts "-- committed: #{j} / #{total_issues} : #{t1 - t0}"
      t0 = t1
    end
    STDERR.puts "== ∆: #{Time.now - t00}"
  end

  def initialize(issue)
    @issue = issue
  end

  def index
    Rails.configuration.batch_commit = true

    solr_doc = generate_solr_doc
    @issue.pages.each_with_index do |page, i|
      # next unless page.id == 70934
      PageIndexer.new(page).index(solr_doc)
      Blacklight.default_index.connection.commit if i % 50 == 0  
    end
    Blacklight.default_index.connection.commit
  end

  def generate_solr_doc
    solr_doc = {}

    d = @issue.date_issued.to_date
    pp @issue
    dt = d.strftime('%B %d, %Y')

    publication = @issue.publication

    # solr_doc[:id] = "#{@issue.ht_namespace}-#{@issue.ht_barcode}-#{@issue.slug}"
    solr_doc[:volume_identifier] = "#{@issue.ht_namespace}-#{@issue.ht_barcode}"
    solr_doc[:issue_identifier] = "#{d.strftime('%Y-%m-%d')}-#{@issue.issue_sequence}-#{@issue.ht_namespace}.#{@issue.ht_barcode}"
    solr_doc[:date_issued_display] = dt
    solr_doc[:issue_no_t] = @issue.issue_no
    solr_doc[:date_issued_dt] = d
    solr_doc[:date_issued_yyyy_ti] = d.strftime('%Y').to_i
    solr_doc[:date_issued_yyyymm_ti] = d.strftime('%Y%m').to_i
    solr_doc[:date_issued_yyyymmdd_ti] = d.strftime('%Y%m%d').to_i
    solr_doc[:date_issued_link] = @issue.slug(false)

    solr_doc[:date_issued_yyyy10_ti] = ( solr_doc[:date_issued_yyyy_ti] / 10 * 10 )
    solr_doc[:date_issued_mm_ti] = d.strftime("%m").to_i
    solr_doc[:date_issued_dd_ti] = d.strftime("%d").to_i

    solr_doc[:ht_barcode] = @issue.ht_barcode
    solr_doc[:ht_namespace] = @issue.ht_namespace
    solr_doc[:publication_link] = publication.slug
    solr_doc[:publication_label] = publication.title
    solr_doc[:issue_sequence] = @issue.issue_sequence
    solr_doc[:pages] = []
    solr_doc[:manifest] = get_image_info(solr_doc[:issue_identifier])
    pp solr_doc[:manifest]

    # solr_doc[:manifest] = get_image_info

    Page.where(issue_id: issue.id).order(:sequence).each do |page|
      # solr_doc[:pages] << [ page.id, page.sequence, page.page_no ]
      solr_doc[:pages] << [
        page.id,
        "#{solr_doc[:id]}-#{page.sequence}",
        page.sequence,
        page.page_no
      ]
    end
    solr_doc
  end

  def get_image_info(issue_identifier)

    info_href = "#{Rails.configuration.manifest_service}#{Rails.configuration.media_collection}?rgn1=issue_identifier&q1=#{issue_identifier}&m_source=1"
    STDERR.puts info_href
    image_uri = URI(info_href)
    response = Net::HTTP.get(image_uri)
    response = JSON.parse(response)
    data = {}
    response['sequences'][0]['canvases'].each do |canvas|
      key = (canvas['@id'].split('/')[-3]).split(':')[-1]
      data[key] = { 'height' => canvas['height'], 'width' => canvas['width'], }
    end
    data

  end


end
