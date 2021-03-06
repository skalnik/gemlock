# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gemlock/version"

Gem::Specification.new do |s|
  s.name        = "gemlock"
  s.version     = Gemlock::VERSION
  s.authors     = ["Mike Skalnik", "Brian Gardner", "Tyler Hastings", "Jabari Worthy"]
  s.email       = ["mskalnik@gatech.edu"]
  s.homepage    = ""
  s.summary     = %q{Get notified when there are updates for gems in your Rails application}
  s.description = %q{When installed, allows a user to check for updates in their Rails application}

  s.rubyforge_project = "gemlock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rake', '>= 0.8.7')
  s.add_dependency('bundler', '>= 1.0.0')
  s.add_dependency('rest-client')
  s.add_dependency('json')

  s.add_development_dependency('rspec' , '~> 2.7.0')
  s.add_development_dependency('mocha' , '~> 0.10.0')
  s.add_development_dependency('pry'   , '>= 0.9.5')
  s.add_development_dependency('vcr'   , '>= 1.11.0')
  s.add_development_dependency('fakeweb', '>= 1.3.0')
end
