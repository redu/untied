# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  describe PublisherObserver do
    before do
      class ::Doorkeeper
        include Untied::Doorkeeper
      end
      PublisherObserver.any_instance.stub(:publisher) do
        publisher = ::Doorkeeper.new
        publisher.watch(User, :after_create)
        publisher.watch(User, :after_update)
        publisher
      end
    end

    context "ActiveRecord::Callbacks" do
      it "should call the observer when the callback is fired" do
        PublisherObserver.instance.should_receive(:after_create)
        User.create
      end

      it "should accept multiple callbacks even in different #watch" do
        PublisherObserver.instance.should_receive(:after_create)
        PublisherObserver.instance.should_receive(:after_update)

        user = User.create(:name => "yo")
        user.update_attributes({:name => "Ops!"})
      end
    end

    context "#producer" do
      it "should return the Producer" do
        PublisherObserver.instance.should respond_to(:producer)
      end
    end

    context "when callbacks are fired" do
      let(:producer) { double('Untied::Producer') }

      ActiveRecord::Callbacks::CALLBACKS.each do |callback|
        it "should publish the event on #{callback}" do
          PublisherObserver.instance.stub(:producer).and_return(producer)

          producer.should_receive(:publish).with(an_instance_of(Event))

          PublisherObserver.instance.send(callback, double('User'))
        end
      end
    end
  end
end
