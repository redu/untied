require 'active_model'
require 'active_record/observer'
require 'active_record/callbacks'

module Untied
  class PublisherObserver < ActiveRecord::Observer
    def initialize
      Untied.config.logger.info "Untied: Initializing publisher observer"

      publisher.define_callbacks
      obs_classes = Proc.new do
        publisher.observed_classes
      end

      self.class.send(:define_method, :observed_classes, obs_classes)
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
      doorkeeper = Untied.config.doorkeeper
      klass = case doorkeeper
      when String then doorkeeper.constantize;
      when Symbol then doorkeeper.to_s.camelize.constantize;
      end

      klass.new
    end
  end
end
