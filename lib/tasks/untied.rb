require "untied"
require "untied/worker"

namespace :untied do
  desc "Starts untied's worker"
  task :work do
    AMQP.start do |connection|
      channel  = AMQP::Channel.new(connection)
      exchange = channel.topic("untied", :auto_delete => true)
      worker = Untied::Worker.new(:channel => channel, :exchange => exchange)
      worker.start
    end
  end
end