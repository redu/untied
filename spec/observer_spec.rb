require 'spec_helper'

module Untied
  describe Observer do
    before do
      class ::UserObserver < Untied::Observer
      end
    end
    after do
      obsc = ::UserObserver
      %w(observed_classes observed_service).each do |method|
        if ::UserObserver.respond_to?(method)
          ::UserObserver.send(:remove_method, method)
        end
      end
    end
    let(:subject) { ::UserObserver.instance }

    context ".instance" do
      it "should return a valid instance of the observer" do
        subject.should be_a Untied::Observer
      end
      it "should be a singleton" do
        subject.should == UserObserver.instance
      end
    end

    context ".observe" do
      context ".observed_classes" do
        it "should define .observed_classes" do
          ::UserObserver.observe(:user, :from => :core)
          subject.observed_classes.should == [User]
        end

        it "should accept multiple classes" do
          ::UserObserver.observe(:user, :post, :from => :core)
          subject.observed_classes.should == [User, Post]
        end

        it "should accept constants" do
          ::UserObserver.observe(User, :from => :core)
          subject.observed_classes.should == [User]
        end
      end

      context ".observed_services" do
        it "should define the observed services" do
          ::UserObserver.observe(User, :from => :core)
          subject.observed_service == :core
        end

        it "should define the observed services as string" do
          ::UserObserver.observe(User, :from => "core")
          subject.observed_service == :core
        end

        context "when omiting service name" do
          it "should default to core" do
            ::UserObserver.observe(User)
            subject.observed_service == :core
          end

          it "should define observed classes" do
            ::UserObserver.observe(User)
            subject.observed_classes.should == [User]
          end
        end
      end
    end

    context "#notify" do
      before do
        ::UserObserver.observe(User)
      end

      it "should respont to #notify" do
        subject.should respond_to :notify
      end

      it "should call the correct method based on event_name" do
        subject.stub(:after_create)
        subject.should_receive(:after_create).with(an_instance_of(Hash))
        subject.notify(:after_create, :user, :core, { :user => { :name => "há!" }})
      end

      it "should not call non callback methods" do
        subject.stub(:after_jump)
        subject.should_not_receive(:after_jump)
        subject.notify(:after_jump, :user, :core, { :user => { :name => "há!" }})
      end

      it "should pass through when the entity comes from other service" do
        subject.stub(:after_create)
        subject.should_not_receive(:after_create)
        subject.notify(:after_create, :user, :foo, { :user => { :name => "há!" }})
      end

      it "should pass trhough when entity is not observed" do
        subject.stub(:after_create)
        subject.should_not_receive(:after_create)
        subject.notify(:after_create, :post, :core, { :user => { :name => "há!" }})
      end
    end
  end
end
