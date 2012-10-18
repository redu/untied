# -*- encoding : utf-8 -*-
module Untied
  class Event
    include ActiveModel::Serializers::JSON
    attr_accessor :name, :payload, :origin

    def initialize(attrs)
      @config = {
        :name => "after_create",
        :payload => nil,
        :origin => Untied.config.service_name
      }.merge(attrs)

      @name = @config.delete(:name)
      @payload = @config.delete(:payload)
      @origin = @config.delete(:origin)
    end

    def attributes
      { "name" => @name, "origin" => @origin, "payload" => @payload }
    end
  end
end
