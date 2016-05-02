class Page < ActiveRecord::Base
  self.table_name = "pages"
  after_save :index_record
  before_destroy :remove_from_index

  #attr_accessible :issue_id, page_no, sequence, text_link, img_link

  def index_record
    return unless Rails.configuration.index_enabled
    i = Issue.find_by_id(issue_id)
    conn = Blacklight.default_index.connection
    d = i.date_issued.to_date
    dt = d.strftime('%B %d, %Y')
    full_text = get_full_text(i, text_link)
    doc = { id: self.id, issue_date_display:dt, issue_no_t:i.issue_no, issue_date_dt: d, issue_id_t: issue_id, 
            page_no_t:page_no, sequence_i: sequence,
            hathitrust_t: i.hathitrust,
            text_link_t: text_link, img_link_t: img_link, full_text_txt:full_text }

    conn.add doc
    conn.commit unless Rails.configuration.batch_commit
  end

  def remove_from_index
    conn = Blacklight.default_index.connection 
    conn.delete_by_id(self.id)
    conn.commit
  end

  def get_full_text(issue, text_link)
    File.read(Rails.root.join(
      Rails.configuration.text_root, 
      issue.hathitrust, 
      text_link+'.txt'))
  end

end
