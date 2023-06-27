class ContactsController < ApplicationController  
  before_action :setup_publication
  before_action :prepend_publication_path

  layout "static"

  def new
    redirect_to(helpers.contact_link)
    # @contact = Contact.new
    # @contact.referer = request.referer if request.referer && request.referer.start_with?(request.base_url)
    # @contact.type = t('views.contacts.types')[params[:type].to_sym] if params[:type]
    # @contact.site_name = t("application_name.#{@publication.slug}")
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    # could use the following to set headers if needed?
    # if @contact.request["contact"]["type"] == "Permissions request or question"

    # not spam and a valid form
    if is_human?(params[:new_google_recaptcha_token]) and ( @contact.respond_to?(:deliver_now) ? @contact.deliver_now : @contact.deliver )
      # flash.now[:notice] = 'Thank you for your message!'
      after_deliver
      render :success
    else
      flash.now[:error] = 'Sorry, this message was not sent successfully. '
      flash.now[:error] << @contact.errors.full_messages.map(&:to_s).join(",")
      render :new
    end
  rescue StandardError => e  
    flash.now[:error] = 'Sorry, this message was not delivered.'
    STDERR.puts e
    render :new
  end

  def after_deliver
    return # unless Sufia::Engine.config.enable_contact_form_delivery
  end

  def setup_publication
    if session[:publication]
      @publication = Publication.where(slug: session[:publication]).first
    else
      @publication = Publication.where(slug: 'midaily').first
    end
    params[:publication] = @publication.slug
    @publication_name = @publication.title
  end

  def prepend_publication_path
    if @publication
      prepend_view_path "app/views/publications/#{@publication.slug}/views/"
    end
  end

  def is_human?(token)
    false
  end
end