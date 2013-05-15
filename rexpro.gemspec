# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rexpro/version'

Gem::Specification.new do |spec|
  spec.name          = "rexpro"
  spec.version       = Rexpro::VERSION
  spec.authors       = ["Lann Martin"]
  spec.email         = ["lann@causes.com"]
  spec.description   = %q{RexPro, a binary protocol for Rexster}
  spec.summary       = <<DESC
RexPro is a binary protocol for Rexster that can be used to send Gremlin
scripts to a remote Rexster instance.
DESC
  spec.homepage      = "https://github.com/lann/rexpro-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "msgpack",     "~> 0.5.4"
  spec.add_dependency "uuid",        "~> 2.3.7"
  spec.add_dependency "tcp_timeout", "~> 0.1.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
