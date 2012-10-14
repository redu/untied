require 'spec_helper'

module Untied
  describe Publisher do
    before do
      # Fake AR subclass
      class Pub
        include Untied::Publisher
      end
    end
    let(:publisher) { Pub.new }

    context "#watch" do
      it "should add observed classes to observed list" do
        publisher.watch(User, :after_create)
        publisher.observed.should == [[User, [:after_create]]]
      end
    end

    context "#define_callbacks" do
      before do
        publisher.watch(User, :after_create)
      end

      it "should add methods to observable" do
        publisher.define_callbacks
        User.new.should \
          respond_to(:_notify_untied__publisher_observer_for_after_create)
      end

      it "should accept multiple classes" do
        publisher.watch(Post, :after_create)
        publisher.define_callbacks

        User.new.should \
          respond_to(:_notify_untied__publisher_observer_for_after_create)
        Post.new.should \
          respond_to(:_notify_untied__publisher_observer_for_after_create)
      end

      it "should accept multiple callbacks" do
        publisher.watch(Post, :after_create, :after_update)
        publisher.define_callbacks

        Post.new.should \
          respond_to(:_notify_untied__publisher_observer_for_after_update)
        Post.new.should \
          respond_to(:_notify_untied__publisher_observer_for_after_create)
      end
    end

    context "#observed_classes" do
      it "should return a list of observed classes" do
        publisher.watch(Post, :after_create)
        publisher.watch(Post, :after_update)
        publisher.watch(User, :after_update)

        publisher.observed_classes.should == [Post, User]
      end
    end
  end
end
