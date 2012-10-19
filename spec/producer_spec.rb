# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Publisher
    describe Producer do
      context "configuration" do
        it "should use service name configured" do
          opts = Producer.new.instance_variable_get(:@opts)
          opts[:service_name].should == 'core'
        end
      end

      it "should initilize producer" do
        Producer.new.should be_a Producer
      end

      it "should raise RuntimeError when trying to run without connection" do
        expect {
          Producer.new(:deliver_messages => true)
        }.to raise_error
      end

      it "should raise RuntimeError if EM is not running" do
        mock_reactor_and_amqp do |c|
          EM.stub("reactor_running?" => false)
          expect {
            Producer.new(:channel => c, :deliver_messages => true)
          }.to raise_error
        end
      end

      context "#publish" do
        it "should call Channel#publish" do
          mock_reactor_and_amqp do |channel|
            e = Event.new(:name => "create", :payload => { :foo => 'bar' }, :origin => :core)
            channel.topic.should_receive(:publish)
            producer = Producer.new(:channel => channel, :deliver_messages => true)
            producer.publish(e)
          end
        end
      end

      def mock_reactor_and_amqp
        # Do nothing when calling start
        Untied.stub(:start).and_return(nil)
        # Simulate reactor running
        EM.stub(:reactor_running?).and_return(true)

        exchange = double('Exchange')
        channel = double('Channel')
        channel.stub(:topic).and_return(exchange)

        yield(channel)
      end
    end
  end
end
