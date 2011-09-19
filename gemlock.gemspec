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

  s.add_development_dependency('rspec' , '~> 2.6.0')
  s.add_development_dependency('mocha' , '~> 0.10.0')
  s.add_development_dependency('pry'   , '>= 0.9.5')
end
