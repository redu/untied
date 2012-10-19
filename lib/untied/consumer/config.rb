# -*- encoding : utf-8 -*-
require 'configurable'
require 'logger'

module Untied
  module Consumer
    def self.configure(&block)
      yield(config) if block_given?
      config.observers.each { |o| o.instance }
    end

    def self.config
      @config ||= Config.new
    end

    class Config
      include Configurable

      config :logger, Logger.new(STDOUT)
      config :observers, []
    end
  end
end


