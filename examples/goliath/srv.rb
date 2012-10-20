# -*- encoding : utf-8 -*-
$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'goliath'
require 'em-synchrony/activerecord'
require 'untied'
require 'untied-publisher'

require 'models/user'

# Defining which ActiveRecord lifecycle events will be observed
class Doorkeeper
  include Untied::Publisher::Doorkeeper

  def initialize
    # Everytime the User's after_create is fired, it will send the user
    # through the message bus
    watch User, :after_create
  end
end

Untied::Publisher.config.doorkeeper = Doorkeeper

# Initializing the publisher observer
Untied::Publisher::Observer.instance

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
