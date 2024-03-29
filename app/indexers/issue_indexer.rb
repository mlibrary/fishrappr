require 'pp'
class IssueIndexer

  attr_accessor :issue

  def self.run(volume_identifier)
    t00 = t0 = Time.now

    ## delete the old entry
    # Blacklight.default_index.connection.delete_by_query "volume_identifier:#{volume_identifier}"

    conn = Blacklight.default_index.connection
    results = conn.get 'select', params: { fq: "volume_identifier:#{volume_identifier}", fl: 'id,volume_identifier', rows: 10000 }
    results['response']['docs'].each do |page_doc|
      conn.delete_by_id page_doc["id"]
      STDERR.puts "-- DELETED #{page_doc['id']}"
    end
    conn.commit

    query = Issue.where(volume_identifier: volume_identifier)

    total_issues = query.count
    query.each_with_index do |issue, j|
      indexer = self.new(issue)
      indexer.index
      t1 = Time.now
      STDERR.puts "-- committed: #{j} / #{total_issues} : #{t1 - t0} : #{issue.issue_identifier}"
      t0 = t1
    end
    Blacklight.default_index.connection.commit
    STDERR.puts "== ∆: #{Time.now - t00}"
  end

  def initialize(issue)
    @issue = issue
  end

  def index(commit=false)
    Rails.configuration.batch_commit = true

    # remove the issue pages because some may have been removed
    unindex_issue

    solr_doc = generate_solr_doc
    @issue.pages.each_with_index do |page, i|
      PageIndexer.new(page).index(solr_doc)
    end
    Blacklight.default_index.connection.commit if commit
  end

  def unindex_issue
    conn = Blacklight.default_index.connection
    results = conn.get 'select', params: { fq: "issue_identifier:#{@issue.issue_identifier}", fl: 'id,volume_identifier', rows: 10000 }
    results['response']['docs'].each do |page_doc|
      conn.delete_by_id page_doc["id"]
      STDERR.puts "-- DELETED #{page_doc['id']}"
    end
  end

  def generate_solr_doc
    solr_doc = {}

    if @issue.date_issued.end_with?('-00-00')
      # stupid mysql
      d = Time.new(@issue.date_issued)
      dt = d.strftime("%Y")
    elsif @issue.date_issued.end_with?('-00')
      d = Time.new(@issue.date_issued)
      dt = d.strftime("%B %Y")
    elsif @issue.date_issued.match(/-\d{4}/)
      d = Date.strptime(@issue.date_issued, "%m-%d-%Y")
      dt = d.strftime("%B %d, %Y")
    else
      begin
        d = @issue.date_issued.to_date
        dt = d.strftime('%B %d, %Y')
      rescue
        # d = Date.new(2021, 1, 1)
        d = nil
        dt = '(unknown date)'
        STDERR.puts "AHOY DATE : #{@issue.issue_identifier} : #{@issue.date_issued}"
      end
    end

    # pp @issue

    publication = @issue.publication

    solr_doc[:volume_identifier] = @issue.volume_identifier || @issue.issue_identifier
    # solr_doc[:issue_identifier] = "#{d.strftime('%Y-%m-%d')}-#{@issue.variant}-#{@issue.volume_identifier}"
    solr_doc[:issue_identifier] = @issue.issue_identifier
    solr_doc[:date_issued_display] = dt
    solr_doc[:issue_number_t] = @issue.issue_number
    solr_doc[:issue_vol_iss_display] = ''
    unless @issue.volume.blank? and @issue.issue_number.blank?
      solr_doc[:issue_vol_iss_display] = "(vol. #{@issue.volume}, iss. #{@issue.issue_number})" # , ed. #{@issue.edition}
    end
    if d
      solr_doc[:date_issued_dt] = d
      solr_doc[:date_issued_yyyy_ti] = d.strftime('%Y').to_i
      solr_doc[:date_issued_yyyymm_ti] = d.strftime('%Y%m').to_i
      solr_doc[:date_issued_yyyymmdd_ti] = d.strftime('%Y%m%d').to_i
      solr_doc[:date_issued_yyyy10_ti] = ( solr_doc[:date_issued_yyyy_ti] / 10 * 10 )
      solr_doc[:date_issued_mm_ti] = d.strftime("%m").to_i
      solr_doc[:date_issued_dd_ti] = d.strftime("%d").to_i
    end

    solr_doc[:date_issued_link] = @issue.slug(false)

    solr_doc[:publication_link] = publication.slug
    solr_doc[:publication_label] = @issue.publication_title
    solr_doc[:variant_sequence] = @issue.variant_sequence
    solr_doc[:pages] = []

    @issue.pages.each do |page|
      solr_doc[:pages] << [
        page.id,
        page.page_identifier,
        page.issue_sequence,
        page.page_number
      ]
    end
    solr_doc
  end


end
