# Sinatra JSON API + Faye PubSub and Angular.js

## Overview

This is a simple Sinatra application using Faye to communicate with an Angular.js client

## Backend

PubSub server with two entities:

PubSub server [Faye](http://faye.jcoglan.com/) with a [Redis](http://redis.io/) server as backend.

Sample backend server using a [Sinatra](http://www.sinatrarb.com/) app to show how messages can be received and sent from the server side.

## Frontend
Javascript sample based on [AngularJS](angularjs.org) and [Faye's client side library](http://faye.jcoglan.com/browser.html)

Instructions
============

1. Clone the repository.
2. Install the following gems:
  + sinatra
  + faye 
  + faye-redis (from git not rubygems)
  + thin
  + json
  > bundle install

## Usage
Run the Faye server on port 9001: 
> rackup faye.ru -s thin -E production -p 9001

Run the Sinatra server on IP 0.0.0.0: 
> rackup config.ru -s thin -o 0.0.0.0