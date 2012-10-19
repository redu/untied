# -*- encoding : utf-8 -*-
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

require 'untied/event'
require 'untied/consumer/consumer'
require 'untied/publisher/publisher'
