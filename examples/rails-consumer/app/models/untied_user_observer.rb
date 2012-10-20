class UntiedUserObserver < Untied::Consumer::Observer
  observe :user, :from => :goliath

  def after_create(payload)
    puts "Creating user"
    User.create(payload.fetch(:user, {}).slice(:name))
  end
end
