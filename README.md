# Untied

Need to register an Observer which observes ActiveRecord models in different applications? Untied Observer for the rescue.

The publisher application registers which models are able to be observed. The consumers just need to define callbacks that will be fired for certain events. The consumer part uses an API similar to the one provided by ActiveRecord::Observer.

[![Build Status](https://travis-ci.org/redu/untied.png)](https://travis-ci.org/redu/untied)

## Installation

Add this line to your application's Gemfile:

    gem 'untied'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install untied

The untied Gem relies on RabbitMQ, so it need to be installed in order to work properly. [Here are](http://www.rabbitmq.com/download.html) the instructions.

## Usage

### Publisher

You need to do some configurations on the publisher side:

```ruby
Untied::Publisher.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.deliver_messages = true # Silent mode when falsy
  config.service_name = "social-network"
  config.doorkeeper = MyDoorkeeper
end
```

The ``service_name`` configuration is very important here. It must be unique across all the services and will be used to uniquely identify the models. The ``deliver_messages``option enable and disable events sending. Disabling it may be useful on test and development environment.

The ``doorkeeper`` configuration let you specify which class is responsible for telling which ActiveRecord models are capable of be observed.

You should also define when the ActiveRecord models will be propagated to other services. We can take advantage on the usefulness of ``ActiveRecord::Callbacks``. To keep the things DRY, this job may be done inside what we call the Watcher:

```ruby
class MyDoorkeeper
  include Untied::Doorkeeper

  def initialize
    watch User, :after_create, :after_update
  end
end
```

The watcher defined above will propagate Users instances when they are created or updated.

### Consumer

On the consumer side, you just need to define the observer as you would with ActiveRecord::Observer. Remember to subclass Untied::Observer instead.

```ruby
class UserObserver < Untied::Consumer::Observer
  observe :user, :from => "social-network"

  def after_create(user)
    puts "A the following user was created on social-network service: #{user}"
  end

  def after_update(user)
    puts "A the following user was updated on social-network service: #{user}"
  end
end
```

One important step is identify which service models the observer is listening to. That's why we user the ``:from`` option on the ``observe`` method.

Activating observers:

```ruby
Untied::Consumer.configure do |config|
  config.observers = [UserObserver]
end
```

## Internals

TODO

## What need to be done?

- Make it ActiveRecord independent.
- Add instructions about how to initialize the worker.
- Failsafeness
- Do not rely on Pub class name


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


<img src="https://github.com/downloads/redu/redupy/redutech-marca.png" alt="Redu Educational Technologies" width="300">

This project is maintained and funded by [Redu Educational Techologies](http://tech.redu.com.br).

# Copyright

Copyright (c) 2012 Redu Educational Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
