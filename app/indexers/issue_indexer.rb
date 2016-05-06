require 'pp'
class IssueIndexer

  attr_accessor :issue

  def self.run
    total_issues = Issue.count
    t0 = Time.now
    Issue.all.each_with_index do |issue, j|
      indexer = self.new(issue)
      indexer.index
      t1 = Time.now
      STDERR.puts "-- committed: #{j} / #{total_issues} : #{t1 - t0}"
      t0 = t1
    end  
  end

  def initialize(issue)
    @issue = issue
  end

  def index
    Rails.configuration.batch_commit = true

    solr_doc = generate_solr_doc
    Page.where(issue_id: issue.id).order(:sequence).each do |page|
      PageIndexer.new(page).index(solr_doc)
    end
    Blacklight.default_index.connection.commit
  end

  def generate_solr_doc
    solr_doc = {}

    d = @issue.date_issued.to_date
    pp @issue
    dt = d.strftime('%B %d, %Y')

    solr_doc[:id] = @issue.date_issued
    solr_doc[:issue_date_display] = dt
    solr_doc[:issue_no_t] = @issue.issue_no
    solr_doc[:issue_date_dt] = d
    solr_doc[:issue_id_t] = @issue.id
    solr_doc[:hathitrust_t] = @issue.hathitrust
    solr_doc[:pages] = []

    Page.where(issue_id: issue.id).order(:sequence).each do |page|
      # solr_doc[:pages] << [ page.id, page.sequence, page.page_no ]
      solr_doc[:pages] << [
        page.id,
        "#{@issue.date_issued}-#{page.sequence}",
        page.sequence,
        page.page_no
      ]
    end
    solr_doc
  end

  t0 = Time.now


end