class Issue < ActiveRecord::Base
  self.table_name = "issues"

  belongs_to :publication
  has_many :pages, -> { order(:issue_sequence) }, dependent: :destroy

  def slug(complete=true)
    retval = self.date_issued
    if complete or self.issue_sequence > 1
      retval = "#{retval}_#{self.issue_sequence}"
    end
    retval
  end
end
