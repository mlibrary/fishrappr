class Publication < ActiveRecord::Base

  has_many :issues, -> { order(:date_issued, :issue_sequence) }, dependent: :destroy
end
