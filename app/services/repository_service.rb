module RepositoryService

  def self.info_url(document, fld='image_link')

  end

  def self.dlxs_repository_url
    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/"
  end  

  def self.dlxs_image_url(document, **kw)
    page_identifier = document.fetch('page_identifier')
    image_link = document.fetch('image_link')

    path_info = []
    path_info << dlxs_identifier(document, 'image_link')

    format = nil
    unless kw.empty?
      path_info << kw.fetch(:region, 'full')
      path_info << kw.fetch(:size, 'full')
      path_info << kw.fetch(:rotation, '0')
      path_info << kw.fetch(:quality, 'default')
      format = kw.fetch(:format, 'jpg')
    end

    path_info = path_info.join('/')
    path_info += "." + format if ( format )

    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/image/#{path_info}"
  end

  def self.dlxs_file_url(document)
    identifier = dlxs_identifier(document)
    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/file/#{identifier}"
  end

  def self.dlxs_manifest_url(document)
    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/manifest/#{dlxs_identifier(document)}"
  end

  def self.dlxs_collection_url(document)
    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api/collection/#{dlxs_identifier(document)}"
  end

  def self.download_pdf_url(rgn1, q1)
    "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/pdf-idx" + "?cc=#{Settings.DLXS_COLLECTION}&rgn1=#{rgn1}&q1=#{q1}&sort=sortable_page_identifier&attachment=1"
  end

  def self.dlxs_identifier(document, fld='image_link')
    return document if document.is_a?(String)
    return document.fetch(fld)
    tmp = [ Settings.DLXS_COLLECTION ]
    tmp << document.fetch('page_identifier')
    tmp << document.fetch(fld)
    tmp.join(':')
  end



end