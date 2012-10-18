# -*- encoding : utf-8 -*-
require 'singleton'

module Untied
  class Observer
    include Singleton
    CALLBACKS = [
      :after_initialize, :after_find, :after_touch, :before_validation,
      :after_validation, :before_save, :around_save, :after_save, :before_create,
      :around_create, :after_create, :before_update, :around_update,
      :after_update, :before_destroy, :around_destroy, :after_destroy,
      :after_commit, :after_rollback
    ]

    class << self
      def observe(*args)
        from, classes = deal_with_args(*args)
        define_observed_classes(classes)
        define_observed_service(from)
      end

      def define_observed_classes(classes)
        remove_possible_method(:observed_classes)
        define_method(:observed_classes, Proc.new { classes })
      end

      def define_observed_service(service)
        remove_possible_method(:observed_service)
        define_method(:observed_service, Proc.new { service })
      end

      private

      def deal_with_args(*args)
        if args.last.is_a? Hash # calling deal_with_args(User, Post, :from =>...
          from = args.delete_at(-1).fetch(:from, :core).to_sym
        else # calling deal_with_args(User, Post..)
          from = :core
        end

        classes = args.collect(&:to_sym)

        [from, classes]
      end
    end

    # Calls the proper callback method if the current observer is configured
    # to observe the event_name from service to the klass.
    #
    #   class MyObserver < Untied::Observer
    #     observe User, :from => :core
    #
    #     def after_create(model); end
    #   end
    #
    #   MyObserver.instance.notify(:after_create, :user, :core, { :user => { } })
    #   # => calls after create method
    #
    #   MyObserver.instance.notify(:after_update, :user, :core, { :user => { } })
    #   # => doesn't calls after create method
    def notify(*args)
      return nil unless args.length == 4

      event_name = args.shift
      klass = args.shift
      service = args.shift
      entity = args.shift

      return nil unless CALLBACKS.include? event_name
      return nil unless service == observed_service
      return nil unless observed_classes.include? klass

      self.send(event_name, entity)
    end

    def observed_classes
      self.class.observed_classes
    end

    def observed_service
      self.class.observed_service
    end
  end
end
