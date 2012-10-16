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

        classes = args.collect do |c|
          c.is_a?(Class) ? c : c.to_s.camelize.constantize
        end

        [from, classes]
      end
    end

    def initialize
      define_callbacks
    end

    def notify(callback, klass, service, payload)
      return nil unless CALLBACKS.include? callback
      return nil unless service == observed_service
      return nil unless observed_classes.include? klass.to_s.camelize.constantize

      self.send(callback, payload)
    end

    def observed_classes
      self.class.observed_classes
    end

    def observed_service
      self.class.observed_service
    end

    def define_callbacks
      defined_callbacks = self.methods.collect(&:to_sym) & CALLBACKS
      observer = self
      consumer = Untied::Consumer
      observer_name = observer.class.to_s.underscore.gsub('/', '__')

      defined_callbacks.each do |callback|
        callback_meth = :"_notify_#{observer_name}_for_#{callback}"
        block = Proc.new do |callback, klass, serivce, payload|
          observer.send(:notify, callback, klass, service, payload)
        end
        puts "defining: #{callback_meth}"
        consumer.send(:define_method, callback_meth, &block)
        consumer.send(:set_callback, :process, :after, callback_meth)
      end
    end

  end
end
