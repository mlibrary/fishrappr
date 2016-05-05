class Page < ActiveRecord::Base
  self.table_name = "pages"
  before_destroy :remove_from_index

  #attr_accessible :issue_id, page_no, sequence, text_link, img_link

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
