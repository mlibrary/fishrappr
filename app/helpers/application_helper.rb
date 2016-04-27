module ApplicationHelper

  def hathitrust_image_src(document, **kw)
    barcode = document.fetch('hathitrust_t').first
    barcode = 'mdp.39015071754159'

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
    %Q{<img src="#{hathitrust_image_src(document, **kw)}" />}.html_safe
  end

  def hathitrust_thumbnail(document, **kw)
    %Q{<img src="#{hathitrust_thumbnail_src(document, **kw)}" />}.html_safe
  end

  def render_date_format(args)
    args.to_date.strftime("%B %d, %Y")
  end  
end
