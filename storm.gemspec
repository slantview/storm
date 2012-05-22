# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'storm/version'

Gem::Specification.new do |s|
  s.name        = "storm"
  s.version     = Storm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Rude"]
  s.email       = ["steve@slantview.com"]
  s.homepage    = "http://github.com/slantview/storm"
  s.summary     = "Website speed testing utility."
  s.description = "Storm is a CLI app to do load testing and other testing of HTTP sites."

  s.add_development_dependency "rspec"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables  = ['storm']
  s.require_path = 'lib'

  s.add_dependency('mixlib-config', '>= 1.0.0')
  s.add_dependency('mixlib-cli', '>= 1.0.0')
  s.add_dependency('mixlib-log', '>= 1.0.0')
end