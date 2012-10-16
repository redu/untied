require 'active_support'
require 'yajl/json_gem'

module Untied
  class Consumer
    include ActiveSupport::Callbacks
    # Middleware?
    define_callbacks :process, :only => :after

    def process(headers, message)
      message = JSON.parse(message, :symbolize_keys => true)
      payload = message[:payload]
      service = message[:origin]
      callback = message[:name]
      klass = message.keys.first

      Untied.config.logger.info \
        "Untied::Consumer: processing message for event #{callback}"
      run_callbacks :process do |callback, klass, service, payload|
      end
    end

  end
end
