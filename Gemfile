source 'https://rubygems.org'
ruby '2.1.1'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'json'
gem 'data_mapper'
gem 'faye'
gem 'thin'
gem 'eventmachine'
gem 'bcrypt'

# When developing an app locally you can use SQLite which is a relational
# database stored in a file. It's easy to set up and just fine for most
# development situations.
group :development do
  gem 'dm-sqlite-adapter'
end

# # Heroku uses Postgres however, so we tell the Gemfile to use Postgres
# # in production instead of SQLite.
group :production do
  gem 'dm-postgres-adapter'
end
