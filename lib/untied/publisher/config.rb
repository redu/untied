# -*- encoding : utf-8 -*-
require 'configurable'
require 'logger'

module Untied
  module Publisher
    def self.configure(&block)
      yield(config) if block_given?
      if config.deliver_messages
        Untied.start
      end
    end

    def self.config
      @config ||= Config.new
    end

    class Config
      include Configurable

      config :logger, Logger.new(STDOUT)
      config :deliver_messages, true
      config :service_name
      config :doorkeeper, nil
    end
  end
end

