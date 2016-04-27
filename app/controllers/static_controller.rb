class StaticController < ApplicationController

  def page

    @page = SolrDocument.new(
      {
        "id":"1",
        "issue_no_t":["1"],
        "issue_date_dt":"1899-09-23T00:00:00Z",
        "issueid_t":["2"],
        "page_no_t":["1"],
        "sequence_i":1,
        "hathitrust_t":["mdp.39015071730837"],
        "text_link_t":["TXT00000005"],
        "img_link_t":["IMG00000005"],
        "timestamp":"2016-04-27T16:03:28.035Z"
      }
    )

  end

end
