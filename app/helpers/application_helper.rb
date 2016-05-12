module ApplicationHelper

  ##
  # Link to the previous document in the current search context
  def link_to_previous_issue_page(previous_document)
    link_opts = {}
    link_to_unless previous_document.nil?, raw(t('views.issue.previous')), url_for_document(previous_document), link_opts do
      content_tag :span, raw(t('views.issue.previous')), :class => 'previous'
    end
  end

  ##
  # Link to the next document in the current search context
  def link_to_next_issue_page(next_document)
    link_opts = {}
    link_to_unless next_document.nil?, raw(t('views.issue.next')), url_for_document(next_document), link_opts do
      content_tag :span, raw(t('views.issue.next')), :class => 'next'
    end
  end

  def hathitrust_image_src(document, **kw)
    barcode = document.fetch('ht_barcode')

    img_link = document.fetch('img_link_t').first

    region = kw.fetch(:region, 'full')
    size = kw.fetch(:size, 'full')
    rotation = kw.fetch(:rotation, '0')
    quality = kw.fetch(:quality, 'default')
    format = kw.fetch(:format, 'jpg')

    "#{Rails.configuration.iiif_service}#{barcode}/#{img_link}/#{region}/#{size}/#{rotation}/#{quality}.#{format}"
  end

  def hathitrust_thumbnail_src(document, **kw)
    size = kw.fetch(:size, ',250')
    hathitrust_image_src(document, size: size)
  end

  def hathitrust_image(document, **kw)
    namespace = document.fetch('ht_namespace')
    return fake_image(document) if namespace == 'fake'
    %Q{<img src="#{hathitrust_image_src(document, **kw)}" />}.html_safe
  end

  def hathitrust_thumbnail(document, **kw)
    namespace = document.fetch('ht_namespace')
    return fake_image(document, kw.fetch(:size, ',250')) if namespace == 'fake'
    %Q{<img src="#{hathitrust_thumbnail_src(document, **kw)}" />}.html_safe
  end

  def render_date_format(args)
    args.to_date.strftime("%B %d, %Y")
  end  

  require 'ffaker'
  def fake_image(document, size=nil)
    namespace = document.fetch('ht_namespace')
    barcode = document.fetch('ht_barcode')
    text_link = document.fetch('text_link')
    issue_no = document.fetch("issue_no_t").first
    page_sequence = document.fetch("sequence")
    key = namespace + "." + barcode + "/" + text_link
    bgcolor = Rails.cache.fetch("#{namespace}.#{barcode}/bgcolor") do
      # [ 'sky', 'vine', 'lava', 'gray', 'industrial', 'social' ].sample
      "#%06x" % rand(0..0xffffff)
    end
    text = "#{issue_no} / #{page_sequence}"
    if size == ',150'
      return holder_tag "110x150", text, nil, {}, { bg: bgcolor }
    elsif size == ",250"
      return holder_tag "187x250", text, nil, {}, { bg: bgcolor }
    elsif size == '200,'
      return holder_tag "200x270", text, nil, {}, { bg: bgcolor }
    else
      # text = Rails.cache.fetch(key) do
      #   FFaker::CheesyLingo.sentence
      # end
      return holder_tag "375x500", text, nil, {}, { bg: bgcolor }
    end
  end
end
