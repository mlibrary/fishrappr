require 'mail_form'

class Contact < MailForm::Base
  #attribute :contact_method, captcha: true
  #attribute :category, validate: true
  attribute :username, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :type
  attribute :message, validate: true
  attribute :referer, validate: false
  # - can't use this without ActiveRecord::Base validates_inclusion_of :issue_type, in: ISSUE_TYPES

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  # 'bhl-digital-support@umich.edu'

  def normal_header
    nh = { 
        subject: "BHL #{@publication.title} Contact Form from #{username} about #{type}",
        to: "#{Settings.contact_address}",
        from: "#{email}"
      }
    return nh
  end

  def permissions_header
    ph = { 
        subject: "BHL #{@publication.title} Contact Form from #{username} about Permissions",
        to: "#{Settings.permissions_address}",
        from: "#{email}"
      }
    return ph
  end

  def headers
    if type == "Permissions request or question"
      permissions_header
    else
      normal_header
    end
  end

end