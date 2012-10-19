# -*- encoding : utf-8 -*-
# Here you should define the method which are going to be called when the
# publisher sends some event.
class Observer < Untied::Consumer::Observer
  observe :user, :from => :goliath

  def after_create(model)
    puts "An user was created on Goliath server, yay!"
  end
end
