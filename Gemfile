source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

## ruby '2.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4', '>= 1.4.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2'

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'loofah', '~> 2.16'

# gem "rack", ">= 2.2.3"

gem 'nokogiri', '~> 1.13', '>= 1.13.4'

gem 'nestive-rails'   # was gem 'nestive', '~> 0.6'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.4'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11', '>= 2.11.5'
## gem 'redis', '~> 4.0'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

gem 'json', '~> 2.6', '>= 2.6.1'

gem 'blacklight', '>= 7.0'
gem 'blacklight_advanced_search', '>= 7.0'
gem "bootstrap", "~> 4.0"

gem 'mail_form', '~> 1.9'
gem 'simple_form', '~> 5.1'
# gem 'simple_form', '~> 5.0', '>= 5.0.3'

gem 'config', '~> 4.0'

gem 'turnout', '~> 2.5'

gem 'google-analytics-rails', '1.1.0'

gem 'rubyzip', '~> 2.3', '>= 2.3.2'
# gem 'ffi', '~> 1.9.24'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
# gem 'bootsnap', '>= 1.1.0', require: false # bootsnap disabled due to issues with fishrappr gml 5-14-18


gem "puma", "~> 5.0"

gem 'sitemap_generator', '~> 6.0.1'

gem "sprockets-rails"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'xray-rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 5.1', '>= 5.1.1'

  gem 'rubocop', '~> 1.30', '>= 1.30.1', require: false
  gem 'rubocop-rspec', '~> 2.11', '>= 2.11.1', require: false
end

# eventually these should be just in development/testing
group :development, :test, :production do
  gem 'holder_rails'
  gem 'ffaker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.7', '>= 3.7.1'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'fakemail'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end


group :production do
  gem 'mysql2', '~> 0.4.4'
end

gem 'rsolr', '~> 2.2.1' # was '~> 4.3.0'
## gem 'blacklight-marc', '~> 6.2.0'

gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'devise-guests', '~> 0.8.1'

group :development, :test do
  # gem 'solr_wrapper', '>= 0.15'
  gem 'solr_wrapper', '~> 4.0', '>= 4.0.2'
end

group :development, :test do
end
