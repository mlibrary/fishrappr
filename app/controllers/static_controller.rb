require 'mail'
class StaticController < ApplicationController

  def email
    # to_str = 'bhl-digital-support@umich.edu'
    to_str = 'gordonl@umich.ed'
    from_str = params['contact']['email']
    subject_str = "Help request from " + params['contact']['username']
    body_str = "MESSAGE: " + params['contact']['message'].to_s + "\n ------------\nCONCERNS:\n "
    params['contact']['type'].each { |item| body_str.concat(item).concat("\n")  } unless params['contact']['type'].nil?

    # Mail.delivery_method :smtp

    Mail.deliver do
      from     from_str
      to       to_str
      subject  subject_str
      body     body_str
    end
  end
  
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