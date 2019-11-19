class Publication < ApplicationRecord

  has_many :issues, -> { order(:date_issued, :issue_sequence) }, dependent: :destroy

  def the_title
    return title if title.index(/^the/i)
    return " the #{title}"
  end

end
