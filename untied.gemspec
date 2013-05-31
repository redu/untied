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
  gem.summary       = "Need to register an Observer which observes ActiveRecord models in different applications? Untied Observer for the rescue."
  gem.homepage      = "http://github.com/redu/untied"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"

  gem.add_runtime_dependency "untied-consumer", "~> 0.0.5"
  gem.add_runtime_dependency "untied-publisher", "~> 0.0.7.pre3"
end
