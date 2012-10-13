require 'configurable'
require 'logger'

module Untied
  def self.configure(&block)
    yield(config) if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    include Configurable

    config :logger, Logger.new(STDOUT)
    config :deliver_messages, true
    config :service_name
  end
end

