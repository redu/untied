# -*- encoding : utf-8 -*-
module Untied
  class Railtie < Rails::Railtie
    config.after_initialize do
      #FIXME don't know why should I do this.
      ActiveRecord::Base.observers ||= []
      config.active_record.observers ||= []
      ActiveRecord::Base.observers << Untied::PublisherObserver
      config.active_record.observers << Untied::PublisherObserver
      Untied::PublisherObserver.instance
    end

    rake_tasks do
      load "untied/consumer/tasks/untied.tasks"
    end
  end
end
