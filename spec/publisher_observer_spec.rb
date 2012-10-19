# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Publisher
    describe Publisher do
      before do
        class MyDoorkeeper
          include Untied::Publisher::Doorkeeper
          def initialize
            watch(User, :after_create)
            watch(User, :after_update)
          end
        end
        Untied.config.doorkeeper = MyDoorkeeper
      end
      after { Untied.config.doorkeeper = MyDoorkeeper }

      context ".instance" do
        it "should raise a friendly error when no doorkeeper is defined" do
          Untied.config.doorkeeper = nil
          klass = Class.new(Observer)
          expect {
            klass.instance
          }.to raise_error(/should define a class which includes/)
        end
      end

      context "ActiveRecord::Callbacks" do
        it "should call the observer when the callback is fired" do
          Observer.instance.should_receive(:after_create)
          User.create
        end

        it "should accept multiple callbacks even in different #watch" do
          Observer.instance.should_receive(:after_create)
          Observer.instance.should_receive(:after_update)

          user = User.create(:name => "yo")
          user.update_attributes({:name => "Ops!"})
        end
      end

      context "#producer" do
        it "should return the Producer" do
          Observer.instance.should respond_to(:producer)
        end
      end

      context "when callbacks are fired" do
        let(:producer) { double('Untied::Producer') }

        ActiveRecord::Callbacks::CALLBACKS.each do |callback|
          it "should publish the event on #{callback}" do
            Observer.instance.stub(:producer).and_return(producer)
            producer.should_receive(:publish).with(an_instance_of(Event))
            Observer.instance.send(callback, double('User'))
          end
        end
      end
    end
  end
end
