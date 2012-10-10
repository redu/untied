require "rubygems"
require "bundler/setup"
require "untied"

# The publisher

UntiedObserver.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.deliver_messages = true
  config.service_name = "fake-facebook"
end

class User < ActiveRecord::Base
  include Untied::Observer
  attr_accesible :login, :age

  watch self.class, :after_create
end

## The consumer

class UserObserver < Untied::Observer
  observe "user", :from => "fake-facebook"

  def after_create(user)
    attrs = JSON.parse(user, :stringfy_keys => true)

    User.create do |user|
      user.name = user_attrs[:name]
      user.age = user_attrs[:age]
    end
  end
end


