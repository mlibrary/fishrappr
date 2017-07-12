class RepositoryService

  def initialize(current_user)
    @current_user = current_user
  end

  def info_url(document, fld='image_link')

  end

  def dlxs_repository_url
    retval = "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/api"
    if @current_user
      retval += "/auth"
    end
    retval
  end

  def dlxs_image_url(document, **kw)
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

    action_path = kw[:thumbnail] ? 'cap' : 'image'

    "#{dlxs_repository_url}/#{action_path}/#{path_info}"
  end

  def dlxs_filename(document)
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

  def dlxs_file_url(document)
    identifier = dlxs_identifier(document)
    "#{dlxs_repository_url}/file/#{identifier}"
  end

  def dlxs_manifest_url(document)
    "#{dlxs_repository_url}/manifest/#{dlxs_identifier(document)}"
  end

  def dlxs_collection_url(document)
    "#{dlxs_repository_url}/collection/#{dlxs_identifier(document)}"
  end

  def download_pdf_url(rgn1, q1)
    auth_param = @current_user ? '&auth=1' : ''
    if rgn1 == 'ic_id'
      "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/pdf-idx" + "?cc=#{Settings.DLXS_COLLECTION}&rgn1=#{rgn1}&q1=#{q1}&sort=sortable_page_identifier&attachment=1#{auth_param}"
    else
      "#{Settings.DLXS_SERVICE_URL}/cgi/i/image/request-pdf-idx" + "?cc=#{Settings.DLXS_COLLECTION}&rgn1=#{rgn1}&q1=#{q1}&sort=sortable_page_identifier&attachment=1#{auth_param}"
    end
  end

  def dlxs_identifier(document, fld='image_link')
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