class ContactsController < ApplicationController  
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    # could use the following to set headers if needed?
    # if @contact.request["contact"]["type"] == "Permissions request or question"

  # not spam and a valid form
    if @contact.respond_to?(:deliver_now) ? @contact.deliver_now : @contact.deliver
      flash.now[:notice] = 'Thank you for your message!'
      after_deliver
      @contact = Contact.new
    else
      flash.now[:error] = 'Sorry, this message was not sent successfully. '
      flash.now[:error] << @contact.errors.full_messages.map(&:to_s).join(",")
    end
    render :new
  rescue
    flash.now[:error] = 'Sorry, this message was not delivered.'
    render :new
  end

  def after_deliver
    return # unless Sufia::Engine.config.enable_contact_form_delivery
  end
end