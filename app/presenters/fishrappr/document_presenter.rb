require 'pp'
module Fishrappr
  class DocumentPresenter < Blacklight::DocumentPresenter

    def has_next_page?
      @document['next_page_link'] != nil
    end

    def has_prev_page?
      @document['prev_page_link'] != nil
    end

    def next_page_link
      @document['next_page_sequence_label']
    end

    def next_page_label
      @document['next_page_label']
    end

    def prev_page_link
      @document['prev_page_sequence_label']
    end

    def prev_page_label
      @document['prev_page_label']
    end

    def issue_date
      @document['issue_date_dt'].split('T')[0]
    end

    def has_page_image?
      not @document['img_link'].nil?
    end


  end
end
