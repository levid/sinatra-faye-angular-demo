# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

require File.expand_path('../app', __FILE__)
require 'rubygems'
require 'sinatra'
require './app'

run Sinatra::Application