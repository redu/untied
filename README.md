# Untied

Need to register an Observer which observes ActiveRecord models in different applications? Untied Observer for the rescue.

The publisher application registers which models are able to be observed. The consumers just need to define callbacks that will be fired for certain events. The consumer part uses an API similar to the one provided by ActiveRecord::Observer.

**Build status**

- Untied::Consumer [![Build Status](https://travis-ci.org/redu/untied-consumer.png)](https://travis-ci.org/redu/untied-consumer)
- Untied::Publisher [![Build Status](https://travis-ci.org/redu/untied-publisher.png)](https://travis-ci.org/redu/untied-publisher)

### Publisher

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

The watcher defined above will propagate Users instances when they are created or updated. The ``to_json`` will be called whenever the model is propagated.

#### Models representers

You can use gems such as [ROAR](https://github.com/apotonick/roar) or [representable](https://github.com/apotonick/representable) to define how your models will be mapped into JSONs:

```ruby
require 'roar/representer/json'

module UserRepresenter
  include Roar::Representer::JSON

  property :complete_name

  def complete_name
    "#{self.frist_name} #{self.last_name}"
  end
end

class DoorkeeperWithRepresenter
  include Untied::Doorkeeper

  def initialize
    watch User, :after_create, :represent_with => UserRepresenter
  end
end
```

Untied will extend the user instance with ``UserRepresenter`` just before sending it into the wire.

#### DelayedJob

If you want to publish messages from [DelayedJob](https://github.com/collectiveidea/delayed_job) you should be aware that is necessary to initialize AMQP and Eventmachine again after forking. It's a [known issue](https://github.com/eventmachine/eventmachine/issues/213) that Eventmachine's reactor doesn't survives process forking, so we need to setup again:

```ruby
Delayed::Worker.lifecycle.before(:invoke_job) do
  if !defined?(@@em_thread) && Delayed::Worker.delay_jobs
    Delayed::Worker.logger.info "Initializing EM and AMQP"
    EM.stop if EM.reactor_running?
    @@em_thread = Thread.new do
      EventMachine.run { AMQP.start }
    end
    sleep(0.25)
  end
end
```

#### Adapters

Untied::Publisher has native support to two adapters: [AMQP](https://github.com/ruby-amqp/amqp) and [Bunny](https://github.com/ruby-amqp/bunny) (default). In order to change them use the ``adapter`` configuration:

```ruby
Untied::Publisher.configure do |config|
  config.adapter = :AMQP # the default is :Bunny
end
```

Remember that, due to the async nature of AMQP, the ``:AMQP`` adapter assumes that you are inside a [EventMachine](https://github.com/eventmachine/eventmachine) loop.

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
  config.abort_on_exception = false # default: false
end
```

You should start the consumer running the ``untied:consumer:worker`` Raketask.

The ``abort_on_exception`` configuration tells if the worker should ignore Exception thrown. If set to true the exception and the stacktrace will be logged but the worker will not stop. This is recomended for production environments.

## Internals

TODO

## What need to be done?

- Make it ActiveRecord independent.
- Use something like [serverengine](https://github.com/frsyuki/serverengine) instead of the old [deamons](http://daemons.rubyforge.org/) gem

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
