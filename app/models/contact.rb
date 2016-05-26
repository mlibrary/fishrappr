require 'mail_form'

class Contact < MailForm::Base
  #attribute :contact_method, captcha: true
  #attribute :category, validate: true
  attribute :username, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :type
  attribute :message, validate: true
  # - can't use this without ActiveRecord::Base validates_inclusion_of :issue_type, in: ISSUE_TYPES

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
        subject: "Fishrappr Contact Form from #{username}",
        to: 'gordonl@umich.edu', # 'bhl-digital-support@umich.edu',   # to: Fishrappr.config.contact_email,
        from: "#{email}"
    }
  end
end