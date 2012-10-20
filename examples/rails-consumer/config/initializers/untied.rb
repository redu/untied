Untied::Consumer.configure do |c|
  c.logger = Rails.logger
  c.observers = [UntiedUserObserver]
end
