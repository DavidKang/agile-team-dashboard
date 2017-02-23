source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'semantic-ui-sass', git: 'https://github.com/doabit/semantic-ui-sass.git'

gem 'coffee-rails', '~> 4.2'
gem 'uglifier', '>= 1.3.0'

gem 'therubyracer', platforms: :ruby

gem 'devise'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'turbolinks', '~> 5'

gem 'jbuilder', '~> 2.5'

gem 'holidays'
gem 'kaminari'
gem 'slim'
gem 'slim-rails'
gem 'simple_form'

gem 'pundit'
gem 'fullcalendar-rails'
gem 'momentjs-rails'
gem 'active_hash'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'timecop'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rubocop', '~> 0.47.1', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %>
  # anywhere in the code.
  gem 'web-console', '>= 3.3.0'

  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running
  # in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate', git: 'https://github.com/ctran/annotate_models.git'
end
