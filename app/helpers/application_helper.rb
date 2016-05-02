module ApplicationHelper

  def hathitrust_image_src(document, **kw)
    barcode = document.fetch('hathitrust_t').first

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
    barcode = document.fetch('hathitrust_t').first
    return fake_image if barcode != 'mdp.39015071754159'
    %Q{<img src="#{hathitrust_image_src(document, **kw)}" />}.html_safe
  end

  def hathitrust_thumbnail(document, **kw)
    barcode = document.fetch('hathitrust_t').first
    return fake_image(kw.fetch(:size, ',250')) if barcode != 'mdp.39015071754159'
    %Q{<img src="#{hathitrust_thumbnail_src(document, **kw)}" />}.html_safe
  end

  def render_date_format(args)
    args.to_date.strftime("%B %d, %Y")
  end  

  require 'ffaker'
  def fake_image(size=nil)
    if size == ',150'
      return holder_tag "110x150", FFaker::CheesyLingo.title, nil, {}, { 'random' => 'yes' }
    elsif size == ",250"
      return holder_tag "187x250", FFaker::CheesyLingo.title, nil, {}, { 'random' => 'yes' }
    else
      return holder_tag "375x500", FFaker::CheesyLingo.sentence
    end
  end
end
