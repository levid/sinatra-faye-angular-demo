# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'rubygems'
require 'bundler'

Bundler.require

require './app'
# run Sinatra::Application
run FayeDemo::Api