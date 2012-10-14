require 'active_record'

module SetupActiveRecord
  # Connection
  ar_config = { :test => { :adapter => 'sqlite3', :database => ":memory:" } }
  ActiveRecord::Base.configurations = ar_config
  ActiveRecord::Base.
    establish_connection(ActiveRecord::Base.configurations[:test])

  # Schema
  ActiveRecord::Schema.define do
    create_table :posts, :force => true do |t|
      t.string :title
    end
    create_table :users, :force => true do |t|
      t.string :name
    end
  end

  # Models
  class ::User < ActiveRecord::Base; end
  class ::Post < ActiveRecord::Base; end
end
