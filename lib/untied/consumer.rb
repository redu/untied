# -*- encoding : utf-8 -*-
module Untied
  class Consumer
    attr_reader :observers

    def initialize
      @observers = \
        self.class.observers.collect { |o| o.to_s.camelize.constantize.instance }
    end

    def process(headers, message)
      begin
        message = JSON.parse(message, :symbolize_names => true)
      rescue JSON::ParserError => e
        Untied.config.logger "Untied::Consumer: Parsing error #{e}"
        return
      end

      message = message.fetch(:event, {})
      payload = message.fetch(:payload, {})
      service = message[:origin].try(:to_sym)
      event_name = message[:name].try(:to_sym)
      klass = payload.keys.first

      Untied.config.logger.info \
        "Untied::Consumer: processing event #{event_name} from #{service} with " + \
        "payload #{payload}"

      observers.each do |observer|
        observer.notify(event_name, klass, service, payload)
      end
    end

    class << self
      def observers=(*obs)
        @observers = obs.flatten
      end

      def observers
        @observers ||= []
      end
    end

  end
end
