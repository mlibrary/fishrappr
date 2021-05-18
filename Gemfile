source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

## ruby '2.5'

### gem "bootstrap-sass", ">= 3.4.1"
# gem "activestorage", ">= 5.2.1.1"
# gem "activejob", ">= 5.2.1.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '5.2.1'
gem 'rails', '~> 5.2', '>= 5.2.2'
gem 'rails-html-sanitizer', '~> 1.0', '>= 1.0.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.5'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
### gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', ">= 0.2", platforms: :ruby
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "loofah", ">= 2.3.1"
gem "rack", ">= 2.0.8"

gem "nokogiri", ">= 1.10.8"

gem 'nestive-rails'   # was gem 'nestive', '~> 0.6'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
## gem 'redis', '~> 4.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'blacklight', '~> 6.12.0'
gem "blacklight_advanced_search", '~> 6.3.1'
gem 'mail_form', '~> 1.7.1'
gem 'simple_form', '~> 4.0.0'

gem "blacklight_range_limit", '~> 6.2.1'

gem 'bootbox-rails', '~>0.4'

gem 'config', '~> 1.6.1'

# gem 'osullivan', '~> XX'

gem 'turnout', '~> 2.4.0'

gem 'google-analytics-rails', '1.1.0'

gem 'rubyzip', '~> 1.3.0' # will load new rubyzip version
gem 'ffi', '~> 1.9.24'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
# gem 'bootsnap', '>= 1.1.0', require: false # bootsnap disabled due to issues with fishrappr gml 5-14-18


gem 'puma', '~> 4.3'

gem 'sitemap_generator', '~> 6.0.1'

# security update to sprockets
gem 'sprockets', '~> 3.7.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'xray-rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop', '~> 0.49.0', require: false
  gem 'rubocop-rspec', require: false
end

# eventually these should be just in development/testing
group :development, :test, :production do
  gem 'holder_rails'
  gem 'ffaker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
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
gem 'blacklight-marc', '~> 6.2.0'

gem 'devise', '~> 4.7.1' # was '~> 4.4.3'
gem 'devise-guests', '~> 0.6.0'

group :development, :test do
  gem 'solr_wrapper', '>= 0.15'
end

group :development, :test do
end
