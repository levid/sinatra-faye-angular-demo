require 'faye'

# faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 30)
# run faye_server

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 30)

bayeux.bind :handshake do |client_id|
  puts "Handshake - Client ID: #{client_id}"
end

bayeux.bind :subscribe do |client_id, channel|
  puts "Subscribe - Channel: #{channel}, Client ID: #{client_id}"
end

bayeux.bind :unsubscribe do |client_id, channel|
  puts "Unsubscribe - Channel: #{channel}, Client ID: #{client_id}"
end

bayeux.bind :publish do |client_id, channel, data|
  puts "Publish - Channel: #{channel}, Client ID: #{client_id}, Data: #{data}"
end

bayeux.bind :disconnect do |client_id|
  puts "Disconnect - Client ID: #{client_id}"
end

run bayeux