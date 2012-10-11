require 'active_model'
require 'active_record/observer'
require 'active_record/callbacks'

module Untied
  class PublisherObserver < ActiveRecord::Observer
    def initialize
      publisher = Pub.new
      publisher.define_callbacks
      observed_classes = Proc.new do
        publisher.observed_classes
      end

      self.class.send(:define_method, :observed_classes, observed_classes)
      super
    end

    def after_create(model)
      puts "model was created #{model.inspect}"
    end
  end
end
