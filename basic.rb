run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.3'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'

gem 'sass-rails', '~> 5.0'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'
gem 'autoprefixer-rails'
gem 'normalize-rails', '~> 3.0.3'

group :development, :test do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end
RUBY

file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

file 'config/puma.rb', <<-RUBY
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
RUBY

generate(:controller, 'pages', 'home', '--no-helper', '--no-assets', '--skip-routes')
route "root to: 'pages#home'"

run 'rm app/assets/stylesheets/application.css'
file 'app/assets/stylesheets/application.css', <<-CSS
/*
*= require normalize-rails
*= require_self
*= require_tree .
*/
CSS

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
JS

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>TODO</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <%= stylesheet_link_tag    'application', media: 'all' %>
    <%= csrf_meta_tags %>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  </head>
  <body>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

run "README.rdoc"
file 'README.md', <<-MARKDOWN
Product by [flrnt](#)
MARKDOWN

after_bundle do
  run "bundle exec figaro install"
  generate('simple_form:install', '--bootstrap')
  rake 'db:drop db:create db:migrate'
  git :init
  git add: "."
  git commit: %Q{ -m 'initial commit' }
end
