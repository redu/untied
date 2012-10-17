# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'untied/version'

Gem::Specification.new do |gem|
  gem.name          = "untied"
  gem.version       = Untied::VERSION
  gem.authors       = ["Guilherme Cavalcanti"]
  gem.email         = ["guiocavalcanti@gmail.com"]
  gem.description   = "Cross application ActiveRecord::Observer"
  gem.summary       = "Need to register an Observer which observes ActiveRecord models in differente applications? Untied Observer for the rescue."
  gem.homepage      = "http://github.com/redu/untied"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.executables   << "untied_worker"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "ruby-debug"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "amqp"

  gem.add_runtime_dependency "activerecord"
  gem.add_runtime_dependency "configurable"
  gem.add_runtime_dependency "json"

end
