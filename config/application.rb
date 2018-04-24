require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fishrappr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Needed for devise loading 4-20-18 gml
    config.autoload_paths += Dir["#{config.root}/lib"]

    # URL for logging the user out of Cosign
    config.logout_prefix = "https://weblogin.umich.edu/cgi-bin/logout?"

    # 4-19-18 gml I looks like these are used later so I'm leaving 'em'
    config.index_enabled = true
    config.batch_commit = true

  end
end
