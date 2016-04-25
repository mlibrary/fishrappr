class Page < ActiveRecord::Base
  self.table_name = "pages"
  after_save :index_record
  before_destroy :remove_from_index

  #attr_accessible :issue_id, page_no, sequence, text_link, img_link

  def index_record
    i = Issue.find_by_id(issue_id)
    conn = Blacklight.default_index.connection
    d = i.date_issued.to_date
    doc = { id: self.id, issue_no_t:i.issue_no, issue_date_dt: d, page_no_t:page_no, issueid_t: issue_id, sequence_i: sequence, text_link_t: text_link, img_link_t: img_link }
    conn.add doc
    conn.commit
  end

  def remove_from_index
    conn = Blacklight.default_index.connection 
    conn.delete_by_id(self.id)
    conn.commit
  end

end
