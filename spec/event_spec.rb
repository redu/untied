# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  describe Event do
    before do
      class Person
        include ActiveModel::Serializers::JSON
        attr_accessor :name

        def initialize(attrs)
          @name = attrs[:name]
        end

        def attributes
          { :name => name }
        end
      end
    end
    let(:person) { Person.new(:name => "Guila") }

    context ".new" do
      it "should accept an event name and a payload" do
        Event.new(:name => :after_create, :payload => double('User')).
          should be_a Event
      end

      it "should include the origin service name" do
        Event.new(:name => :after_create, :payload => person).
          origin.should == "core"
      end
    end

    context "#to_json" do
      it "should generte the correct json representation" do
        event = {
          :event => {
            :name => :after_create,
            :payload => person,
            :origin => :core
          }
        }
        Event.new(:name => :after_create, :payload => person).to_json == \
          event.to_json
      end

    end
  end
end
