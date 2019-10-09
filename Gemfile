source 'https://rubygems.org'
ruby '2.6.3'

#  sidekiq allows for fetching in background
gem 'sidekiq'
gem 'sidekiq-failures', '~> 1.0'

#  redit is necessary for sidekiq to work
gem 'redis'

# sentiment analyzes horoscopes content
gem 'sentiment_lib'

# i don't know what the sinatra gem is doing here
gem 'sinatra', '>= 2.0.0.beta2', require: false

# pagination gems

gem 'will_paginate'
gem 'kaminari'
gem 'pagy'
gem 'pager_api'

#  setup gems for rails app
gem 'bootsnap', require: false
gem 'devise'
gem 'jbuilder', '~> 2.0'
gem 'pg', '~> 0.21'
gem 'puma'
gem 'rails', '5.2.3'
gem 'pundit'
gem 'autoprefixer-rails'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'sassc-rails'
gem "simple_form", ">= 5.0.0"
gem 'uglifier'
gem 'webpacker'

group :development do
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'dotenv-rails'
end
