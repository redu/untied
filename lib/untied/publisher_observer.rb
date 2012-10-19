# -*- encoding : utf-8 -*-
require 'active_model'
require 'active_record/observer'
require 'active_record/callbacks'

module Untied
  class PublisherObserver < ActiveRecord::Observer
    def initialize
      Untied.config.logger.info "Untied: Initializing publisher observer"

      publisher.define_callbacks
      observed = publisher.observed_classes

      self.class.send(:define_method, :observed_classes, Proc.new { observed })
      super
    end

    def method_missing(name, model, *args, &block)
      if ActiveRecord::Callbacks::CALLBACKS.include?(name)
        produce_event(name, model)
      else
        super
      end
    end

    protected

    def produce_event(callback, model)
      producer.publish Event.new(:name => callback, :payload => model)
    end

    def producer
      Producer.new
    end

    def publisher
      doorkeeper_config = Untied.config.doorkeeper
      @doorkeeper ||= begin
        klass = case doorkeeper_config
          when String then doorkeeper_config.constantize;
          when Symbol then doorkeeper_config.to_s.camelize.constantize;
          else
            doorkeeper_config
          end

          klass.new
        rescue NameError => e
          raise NameError.new "You should define a class which includes " + \
            "Untied::Doorkeeper and set it name to Untied.config.doorkeeper."
        end
    end
  end
end
