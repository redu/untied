module Untied
  module Consumer

  end
end

require 'untied/event'
require 'untied/consumer/processor'
require 'untied/consumer/observer'
require 'untied/consumer/railtie' if defined?(Rails)
