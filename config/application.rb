require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fishrappr
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.ht_host = 'https://beta-3.babel.hathitrust.org'
    # config.ht_service = config.ht_host + '/cgi/imgsrv/'
    # config.iiif_service = config.ht_service + 'iiif/'
    # config.download_service = config.ht_service + 'download/pdf'
    config.sdrdataroot = "tmp/sdr1/obj"

    config.media_host = 'https://roger.quod.lib.umich.edu'
    config.media_service = config.media_host + '/cgi/i/image/api/'
    config.iiif_service = config.media_host + '/cgi/i/image/api/image/'
    config.manifest_service = config.media_host + '/cgi/i/image/api/manifest/'
    config.download_service = config.media_host + '/cgi/i/image/pdf-idx'
    config.media_collection = 'bhl_midaily'

    config.index_enabled = true
    config.batch_commit = true

    config.autoload_paths += Dir["#{config.root}/lib"]

    config.default_publication = 'the-michigan-daily'

    # fishrappr emails
    config.contact_address = "bhl-digital-support@umich.edu"
    config.permissions_address = "bhl-student-pub-contact@umich.edu"

  end
end
