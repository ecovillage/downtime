# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'downtime/version'

Gem::Specification.new do |spec|
  spec.name          = "downtime"
  spec.version       = Downtime::VERSION
  spec.authors       = ["Felix Wolfsteller"]
  spec.email         = ["felix.wolfsteller@gmail.com"]
  spec.summary       = %q{Monitors your internet connection}
  spec.description   = %q{Calls dig and updates up- and downtime information}
  spec.homepage      = ""
  spec.license       = "GPL-3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
