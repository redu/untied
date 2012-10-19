# -*- encoding : utf-8 -*-
require 'active_model'

module Untied
  class Event
    include ActiveModel::Serializers::JSON
    attr_accessor :name, :payload, :origin

    def initialize(attrs)
      @config = {
        :name => "after_create",
        :payload => nil,
        :origin => nil
      }.merge(attrs)

      raise "You should inform the origin service" unless @config[:origin]

      @name = @config.delete(:name)
      @payload = @config.delete(:payload)
      @origin = @config.delete(:origin)
    end

    def attributes
      { "name" => @name, "origin" => @origin, "payload" => @payload }
    end
  end
end
