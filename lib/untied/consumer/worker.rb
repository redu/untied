# -*- encoding : utf-8 -*-
module Untied
  module Consumer
    class Worker
      def initialize(opts)
        @channel = opts[:channel]
        @queue_name = opts[:queue_name] || ""
        @consumer = opts[:consumer] || Processor.new
        @exchange = opts[:exchange]

        Untied.config.logger.info "Worker initialized and listening"
      end

      def start
        @channel.queue(@queue_name, :exclusive => true) do |queue|
          queue.bind(@exchange, :routing_key => "untied.#").subscribe do |h,p|
            @consumer.process(h,p)
          end
        end
      end
    end
  end
end
