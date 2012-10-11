require 'spec_helper'

module Untied
  describe PublisherObserver do
    before do
      # Fake AR subclass
      class User
        extend ActiveModel::Callbacks
        define_model_callbacks :create

        def create
          _run_create_callbacks {  }
        end
      end

      class Post
        extend ActiveModel::Callbacks
        define_model_callbacks :create, :update

        def create
          _run_create_callbacks {  }
        end

        def update
          _run_update_callbacks {  }
        end
      end

      class Pub
        include Untied::Publisher
      end
    end
    let(:publisher) { Pub.new }

    context "callbacks" do
      before do
        PublisherObserver.stub(:instance).
          and_return(double('Untied::PublisherObserver'))

        publisher.watch(User, :after_create)
        publisher.watch(Post, :after_update)
      end

      it "should call the observer when the callback is fired" do
        publisher.define_callbacks
        PublisherObserver.instance.should_receive(:after_create)
        User.new.create
      end

      it "should accept multiple callbacks even in differents #watch" do
        publisher.watch(Post, :after_create)
        publisher.define_callbacks

        PublisherObserver.instance.should_receive(:after_create)
        PublisherObserver.instance.should_receive(:after_update)
        Post.new.create
        Post.new.update
      end
    end
  end
end
