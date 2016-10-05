require 'pp'
class IssueIndexer

  attr_accessor :issue

  def self.run(volume_identifier)
    t00 = t0 = Time.now
    query = Issue.where(volume_identifier: volume_identifier)
    total_issues = query.count
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

    solr_doc[:volume_identifier] = @issue.volume_identifier
    # solr_doc[:issue_identifier] = "#{d.strftime('%Y-%m-%d')}-#{@issue.variant}-#{@issue.volume_identifier}"
    solr_doc[:issue_identifier] = "#{@issue.volume_identifier}-#{d.strftime('%Y-%m-%d')}-#{@issue.variant}"
    solr_doc[:date_issued_display] = dt
    solr_doc[:issue_no_t] = @issue.issue_no
    solr_doc[:issue_vol_iss_display] = "(vol. #{@issue.volume}, iss. #{@issue.issue_no}, ed. #{@issue.edition})"
    solr_doc[:date_issued_dt] = d
    solr_doc[:date_issued_yyyy_ti] = d.strftime('%Y').to_i
    solr_doc[:date_issued_yyyymm_ti] = d.strftime('%Y%m').to_i
    solr_doc[:date_issued_yyyymmdd_ti] = d.strftime('%Y%m%d').to_i
    solr_doc[:date_issued_link] = @issue.slug(false)

    solr_doc[:date_issued_yyyy10_ti] = ( solr_doc[:date_issued_yyyy_ti] / 10 * 10 )
    solr_doc[:date_issued_mm_ti] = d.strftime("%m").to_i
    solr_doc[:date_issued_dd_ti] = d.strftime("%d").to_i

    solr_doc[:publication_link] = publication.slug
    solr_doc[:publication_label] = @issue.publication_title
    solr_doc[:variant_sequence] = @issue.variant
    solr_doc[:pages] = []
    solr_doc[:manifest] = get_image_info(solr_doc[:issue_identifier])
    pp solr_doc[:manifest]

    # solr_doc[:manifest] = get_image_info

    @issue.pages.each do |page|
      solr_doc[:pages] << [
        page.id,
        page.page_identifier,
        page.issue_sequence,
        page.page_no
      ]
    end
    solr_doc
  end

  def get_image_info(issue_identifier)

    info_href = "#{Rails.configuration.media_service}manifest/#{Rails.configuration.media_collection}?rgn1=issue_identifier&q1=#{issue_identifier}&m_source=1"
    STDERR.puts info_href
    image_uri = URI(info_href)
    response = Net::HTTP.get(image_uri)
    response = JSON.parse(response)
    data = {}
    response['sequences'][0]['canvases'].each do |canvas|
      # key = (canvas['@id'].split('/')[-3]).split(':')[-1]
      image_basename = canvas['images'][0]['resource']['service']['@id'].split(':').last
      data[image_basename] = { 'height' => canvas['height'], 'width' => canvas['width'], }
    end
    data

  end


end
