require 'em-synchrony/activerecord'

CONFIG = { Goliath.env.to_sym => { :adapter => 'sqlite3', :database => ":memory:" } }
ActiveRecord::Base.configurations = CONFIG
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Goliath.env])

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :name
    t.timestamp :created_at
    t.timestamp :updated_at
  end
end

Untied.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.deliver_messages = true
  config.service_name = "goliath"
  config.doorkeeper = "Doorkeeper"
end
