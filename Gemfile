source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.0', '>= 6.0.6.1'
gem 'webpacker'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
### gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', "~> 0.5", platforms: :ruby
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "rack", ">= 2.2.6.2"

gem 'rails-html-sanitizer', '~> 1.6'
gem "loofah", "~> 2.21"
gem 'nokogiri', '~> 1.16', '>= 1.16.6'

## gem 'nestive-rails'   # was gem 'nestive', '~> 0.6'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.6'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.12'

gem 'json', '~> 2.7', '>= 2.7.2'

gem 'blacklight', '~> 7.37'
gem 'blacklight_advanced_search', '~> 7.0'
# gem 'bootstrap', '~> 4.0'
gem 'bootstrap', '~> 4.6', '>= 4.6.2'
## gem 'blacklight_range_limit', '~> 8.5'

gem 'bootbox-rails', '~> 0.5.0'

# gem 'config', '~> 1.6.1'
gem 'config', '~> 5.5', '>= 5.5.1'

# gem 'osullivan', '~> XX'

gem 'turnout', '~> 2.5'

gem 'rubyzip', '~> 2.3', '>= 2.3.2'
gem 'ffi', '~> 1.17'

gem 'puma', '~> 6.4', '>= 6.4.2'

gem 'sitemap_generator', '~> 6.3.0'

# # security update to sprockets
# gem 'sprockets', '~> 3.7.2'

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
  # gem 'rubocop', '~> 0.49.0', require: false
  # gem 'rubocop-rspec', require: false
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
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15', '< 4.0'
  # gem 'selenium-webdriver'
  # # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
end


group :production do
  gem 'mysql2', '~> 0.5.6'
end

gem 'rsolr', '~> 2.6.0' # was '~> 4.3.0'

gem 'devise', '~> 4.9.4' # was '~> 4.4.3'
gem 'devise-guests', '~> 0.8.3'

group :development, :test do
end
