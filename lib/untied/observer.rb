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
        from = if args.last.is_a?(Hash)
                 args.last.fetch(:from, "core").to_sym
               else
                 :core
               end

        classes = args[0..-2].collect do |klass|
          case klass
          when Symbol, String then
            klass.to_s.camelize.constantize
          else
            klass
          end
        end

        [from, classes]
      end
    end

    def notify(callback, klass, service, payload)
      return nil unless CALLBACKS.include? callback
      return nil unless service == observed_service

      self.send(callback, payload)
    end

    def observed_classes
      self.class.observed_classes
    end


    def observed_service
      self.class.observed_service
    end
  end
end
