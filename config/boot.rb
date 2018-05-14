ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# bootsnap disabled due to issues with fishrappr gml 5-14-18
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
