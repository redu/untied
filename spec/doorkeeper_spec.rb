# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Publisher
    describe Doorkeeper do
      before do
        class ::Doorkeeper
          include Untied::Publisher::Doorkeeper
        end
      end
      let(:doorkeeper) { ::Doorkeeper.new }

      context "#watch" do
        it "should add observed classes to observed list" do
          doorkeeper.watch(User, :after_create)
          doorkeeper.observed.should == [[User, [:after_create]]]
        end
      end

      context "#define_callbacks" do
        before do
          doorkeeper.watch(User, :after_create)
        end

        it "should add methods to observable" do
          doorkeeper.define_callbacks
          User.new.should \
            respond_to(:_notify_untied__publisher__observer_for_after_create)
        end

        it "should accept multiple classes" do
          doorkeeper.watch(Post, :after_create)
          doorkeeper.define_callbacks

          User.new.should \
            respond_to(:_notify_untied__publisher__observer_for_after_create)
          Post.new.should \
            respond_to(:_notify_untied__publisher__observer_for_after_create)
        end

        it "should accept multiple callbacks" do
          doorkeeper.watch(Post, :after_create, :after_update)
          doorkeeper.define_callbacks

          Post.new.should \
            respond_to(:_notify_untied__publisher__observer_for_after_update)
          Post.new.should \
            respond_to(:_notify_untied__publisher__observer_for_after_create)
        end
      end

      context "#observed_classes" do
        it "should return a list of observed classes" do
          doorkeeper.watch(Post, :after_create)
          doorkeeper.watch(Post, :after_update)
          doorkeeper.watch(User, :after_update)

          doorkeeper.observed_classes.should == [Post, User]
        end
      end
    end
  end
end
