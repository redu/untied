#!/usr/bin/env ruby
# Installing:
#   bundle install
#
# To startup the server and the Untied publisher:
#   ruby srv.rb -sv
#
# To startup the consumer:
#   rake untied:work
#
# Usage:
#
# Create an user via Goliath REST API:
#
#   curl -X POST http://0.0.0.0:9000?name=guila
#   => "{\"user\":{\"created_at\":\"2012-10-18T09:26:57-03:00\",\"id\":1,\"name\":\"guila\",\"updated_at\":\"2012-10-18T09:26:57-03:00\"}}"
#
# The consumer should output:
#
#   I, [2012-10-18T09:59:14.927815 #9133]  INFO -- : Untied::Consumer: processing event after_create from goliath with payload {:user=>{:created_at=>"2012-10-18T09:59:14-03:00", :id=>1, :name=>"guila", :updated_at=>"2012-10-18T09:59:14-03:00"}}
#   An user was created on Goliath server, yay!

$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'goliath'
require 'em-synchrony/activerecord'
require 'untied'

require 'models/user'

# Defining which ActiveRecord lifecycle events will be observed
class Doorkeeper
  include Untied::Doorkeeper

  def initialize
    # Everytime the User's after_create is fired, it will send the user
    # through the message bus
    watch User, :after_create
  end
end

# Initializing the publisher observer
Untied::PublisherObserver.instance

class Srv < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::DefaultMimeType
  use Goliath::Rack::Render, 'json'

  def response(env)
    if env['REQUEST_METHOD'] == 'GET'
      begin
        user = User.find(params['id'])
        [200, {}, user.to_json]
      rescue ActiveRecord::RecordNotFound => e
        [404, {}, {:error => e.message}.to_json]
      end
    else
      user = User.create(params)
      [200, {}, user.to_json]
    end
  end
end
