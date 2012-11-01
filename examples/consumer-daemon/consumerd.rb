$:.unshift File.expand_path(File.dirname(__FILE__))

require "bundler/setup"
require "amqp"
require "untied-consumer"
require "untied-consumer/worker"
require "daemons"

require "observer"

# Enabling the observer defined in observer.rb
Untied::Consumer.configure do |c|
  c.observers = [Observer]
end

log_dir = File.expand_path File.join(File.dirname(__FILE__), 'log')
pids_dir = File.expand_path File.join(File.dirname(__FILE__), 'tmp', 'pids')

worker = Untied::Consumer::Worker.new
worker.daemonize(:pids_dir => pids_dir, :log_dir => log_dir)
