class PageIndexer

  attr_accessor :page

  def initialize(page)
    @page = page
  end

  def generate_solr_doc(issue_doc)

    full_text = get_full_text(issue_doc[:hathitrust_t], @page.text_link)
    solr_doc = { 
      id: @page.id,
      page_no_t:@page.page_no, sequence_i: @page.sequence,
      text_link_t: @page.text_link, 
      img_link_t: @page.img_link, 
      full_text_txt:full_text,
      next_page_id_i: nil,
      prev_page_id_i: nil,
      next_page_sequence_i: nil,
      prev_page_sequence_i: nil,
      next_page_display: nil,
      prev_page_display: nil
    }

    current_index = issue_doc[:pages].index { |v| v[0] == @page.id }
    [:issue_date_display, :issue_no_t, :issue_date_dt, :issue_id_t, :hathitrust_t].each do |key|
      solr_doc[key] = issue_doc[key]
    end

    unless current_index - 1 < 0
      solr_doc[:prev_page_id_i] = issue_doc[:pages][current_index - 1][0]
      solr_doc[:prev_page_sequence_i] = issue_doc[:pages][current_index - 1][1]
      solr_doc[:prev_page_display] = issue_doc[:pages][current_index - 1][2]
    end
    if current_index + 1 < ( issue_doc[:pages].size - 1 )
      solr_doc[:next_page_id_i] = issue_doc[:pages][current_index + 1][0]
      solr_doc[:next_page_sequence_i] = issue_doc[:pages][current_index + 1][1]
      solr_doc[:next_page_display] = issue_doc[:pages][current_index + 1][2]
    end

    solr_doc
  end

  def index(issue_doc)
    solr_doc = generate_solr_doc(issue_doc)
    conn = Blacklight.default_index.connection
    conn.add solr_doc
  end

  def get_full_text(issue_hathitrust, text_link)
    File.read(Rails.root.join(
      Rails.configuration.text_root, 
      issue_hathitrust, 
      text_link+'.txt'))
  end

end