# -*- encoding : utf-8 -*-
# Here you should define the method which are going to be called when the
# publisher sends some event.
class Observer < Untied::Consumer::Observer
  observe :user, :from => :core

  def after_create(model)
    puts "An user was created on Goliath server, yay!"
    puts model.inspect
  end

  def after_update(model)
    puts "An user was created on Goliath server, yay!"
    puts model.inspect
  end
end
