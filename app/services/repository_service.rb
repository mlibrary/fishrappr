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

  def self.dlxs_filename(document)
    identifier = dlxs_identifier(document)
    # bhl_midaily:mdp.39015071730621-00000003:TXT00000003 
    parts = identifier.split(":")
    namespace, barcode, sequence = parts[1].split(/[\.-]/)

    path = barcode.scan(/.{2}/)

    filename = []
    filename << ENV['USE_FILESYSTEM']
    if ENV['USE_FILESYSTEM_INCLUDE_NAMESPACE']
      filename << namespace
    end
    filename << "pairtree_root"
    filename << path
    filename << barcode
    filename << sequence + ".txt.gz"
    filename.flatten.join("/")
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
    if document.is_a?(String)
      unless document.start_with?(Settings.DLXS_COLLECTION)
        document = [ Settings.DLXS_COLLECTION, document, '1' ].join(':')
      end
      return document
    end
    return document.fetch(fld, nil)
    tmp = [ Settings.DLXS_COLLECTION ]
    tmp << document.fetch('page_identifier')
    tmp << document.fetch(fld)
    tmp.join(':')
  end



end