# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Consumer
    describe Processor do
      before do
        class ::SomeObserver < Observer
          observe :user, :from => :core
        end
        class MyProcessor < Processor
        end
      end
      after do
        MyProcessor.observers = []
      end
      let(:message) do
        { :event => {
          :name => :after_create, :origin => :core,
          :payload => { :user => { :name => "Guila" } }
        } }
      end

      context ".observers=" do
        it "should accept a list of observers" do
          MyProcessor.observers = [:my_observer, :other_observers]
          MyProcessor.observers.should == [:my_observer, :other_observers]
        end
      end

      context ".new" do
        before { MyProcessor.observers = [:some_observer] }
        it "should initialize observers" do
          SomeObserver.should_receive(:instance)
          MyProcessor.new
        end

        it "should assing observer to a instance variable" do
          MyProcessor.new.observers.should include SomeObserver.instance
        end
      end

      context "#process" do
        before { MyProcessor.observers = [:some_observer] }
        it "should call Observer#notify" do
          SomeObserver.instance.should_receive(:notify)
          MyProcessor.new.process({}, message.to_json)
        end

        it "should call Observer#notify with correct arguments" do
          SomeObserver.instance.should_receive(:notify).
            with(:after_create, :user, :core, { :user => { :name => "Guila" } })
          MyProcessor.new.process({}, message.to_json)
        end

        it "should not fail if there is parsing error" do
          expect {
            MyProcessor.new.process({}, "guila")
          }.to_not raise_error(JSON::ParserError)
        end

        it "should not fail if the message doesn't meet the protocol" do
          expect {
            MyProcessor.new.process({}, {})
          }.to_not raise_error(NoMethodError)
        end
      end
    end
  end
end
