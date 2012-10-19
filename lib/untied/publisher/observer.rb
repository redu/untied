# -*- encoding : utf-8 -*-
require 'active_model'
require 'active_record/observer'
require 'active_record/callbacks'

module Untied
  module Publisher
    class Observer < ActiveRecord::Observer
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
        return @publisher if defined?(@publisher)

        unless Untied.config.doorkeeper
          raise NameError.new "You should define a class which includes " + \
            "Untied::Doorkeeper and set it name to Untied.config.doorkeeper."
        end
        @publisher = Untied.config.doorkeeper.new
      end
    end
  end
end
