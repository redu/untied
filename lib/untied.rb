require 'untied/version'

require 'rubygems'
require 'bundler/setup'
require 'amqp/utilities/event_loop_helper'

module Untied
  def self.start
    Thread.abort_on_exception = false

    AMQP::Utilities::EventLoopHelper.run do
      AMQP.start
    end

    EventMachine.next_tick do
      AMQP.channel ||= AMQP::Channel.new(AMQP.connection)
    end
  end
end

require 'untied/config'
require 'untied/observer'
require 'untied/consumer'
require 'untied/producer'
require 'untied/publisher_observer'
require 'untied/doorkeeper'
require 'untied/event'
