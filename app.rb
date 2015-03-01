require 'data_mapper'
require 'sinatra/base'
require 'sinatra/namespace'

# Our simple hello-world app
module IcueDemo
  class App < Sinatra::Base

    def initalize

    end

    register Sinatra::Namespace
    # threaded - False: Will take requests on the reactor thread
    #            True:  Will queue request for background thread
    configure do
      set :threaded, false
    end

    # Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
    # set, when working locally this line will fall back to using SQLite in the
    # current directory.
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

    # Define a simple DataMapper model.
    class Thing
      include DataMapper::Resource

      property :id, Serial, :key => true
      property :created_at, DateTime
      property :title, String, :length => 255
      property :description, Text
    end

    # Finalize the DataMapper models.
    DataMapper.finalize

    # Tell DataMapper to update the database according to the definitions above.
    DataMapper.auto_upgrade!

    not_found do
      content_type :json
      halt 404, { error: 'URL not found' }.to_json
    end

    get '/' do
      send_file './public/index.html'
      # redirect '/index.html'
    end

    post '/' do
      msg = JSON.parse(request.body.read)
      puts "< %s" % msg
      msg.to_json

      # DataService.send("You asked me to send: #{msg}")

      # publication.callback do
      #   puts 'Message received by server!!!!'
      # end

      # publication.errback do |error|
      #   puts 'There was a problem: ' + error.message
      # end

      # bayeux.get_client.publish('/fromserver', {
      #   'text'      => 'New email has arrived!',
      #   'inboxSize' => 34
      # })
    end

    post '/login' do
      params = @request_payload[:user]

      user = User.find(email: params[:email])
      if user.password == params[:password] #compare the hash to the string; magic
        user.generate_token!
        {token: user.token}.to_json # make sure you give hte user the token
      else
        #tell the user they aren't logged in
      end
    end


    # Request runs on the reactor thread (with threaded set to false)
    get '/hello' do
      content_type :json
      { message: 'Hello World!' }.to_json
    end

    # Request runs on the reactor thread (with threaded set to false)
    # and returns immediately. The deferred task does not delay the
    # response from the web-service.
    get '/delayed-hello' do
      EM.defer do
        sleep 5
      end
      'I\'m doing work in the background, but I am still free to take requests'
    end

    namespace '/api' do
      # Route to show all Things, ordered like a blog
      get '/things' do
        content_type :json
        @things = Thing.all(:order => :created_at.desc)
        @things.to_json
      end

      get '/chart-data' do
        num_arr = (0..50).to_a.shuffle
        # $client.publish '/chart-data/update', num_arr.to_json
        num_arr.to_json
      end

      # CREATE: Route to create a new Thing
      post '/things' do
        content_type :json

        # These next commented lines are for if you are using Backbone.js
        # JSON is sent in the body of the http request. We need to parse the body
        # from a string into JSON
        # params_json = JSON.parse(request.body.read)

        # If you are using jQuery's ajax functions, the data goes through in the
        # params.
        params = JSON.parse(request.body.read)

        @thing = Thing.new(params)
        # @things = Thing.all(:order => :created_at.desc)

        if @thing.save
          # $client.publish '/things/new', @thing.to_json
          # $client.publish '/things/all', @things.to_json
          @thing.to_json
        else
          halt 500
        end
      end

      # READ: Route to show a specific Thing based on its `id`
      get '/things/:id' do
        content_type :json
        @thing = Thing.get(params[:id].to_i)

        if @thing
          @thing.to_json
        else
          halt 404
        end
      end

      # UPDATE: Route to update a Thing
      put '/things/:id' do
        content_type :json

        # These next commented lines are for if you are using Backbone.js
        # JSON is sent in the body of the http request. We need to parse the body
        # from a string into JSON
        # params_json = JSON.parse(request.body.read)

        # If you are using jQuery's ajax functions, the data goes through in the
        # params.

        @thing = Thing.get(params[:id].to_i)
        @thing.update(params)

        if @thing.save
          @thing.to_json
        else
          halt 500
        end
      end

      # DELETE: Route to delete a Thing
      delete '/things/:id/delete' do
        content_type :json
        @thing = Thing.get(params[:id].to_i)

        if @thing.destroy
          {:success => "ok"}.to_json
        else
          halt 500
        end
      end
    end

    # If there are no Things in the database, add a few.
    if Thing.count == 0
      Thing.create(:title => "Test Thing One", :description => "Sometimes I eat pizza.")
      Thing.create(:title => "Test Thing Two", :description => "Other times I eat cookies.")
    end

    # namespace '/admin' do
    #   helpers AdminHelpers
    #   before  { authenticate unless request.path_info == '/admin/login' }

    #   namespace '/users' do
    #     get do
    #       # Only authenticated users can access here...
    #       @users = User.all
    #       haml :users
    #     end

    #     # More user admin routes...
    #   end

    #   # More admin routes...
    # end
  end
end

# FayeDemo::Api.new