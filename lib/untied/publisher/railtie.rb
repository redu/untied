# -*- encoding : utf-8 -*-
module Untied
  module Publisher
    class Railtie < Rails::Railtie
      config.after_initialize do
        #FIXME don't know why should I do this.
        ActiveRecord::Base.observers ||= []
        config.active_record.observers ||= []
        ActiveRecord::Base.observers << Untied::Publisher::Observer
        config.active_record.observers << Untied::Publisher::Observer
        Untied::Publisher::Observer.instance
      end
    end
  end
end
