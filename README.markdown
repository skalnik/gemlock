Gemlock
=======

Provides rake tasks that allow you to check for out of date gems in a project
using Bundler.

### Travis Status

[![Build Status](https://secure.travis-ci.org/skalnik/gemlock.png)](http://travis-ci.org/skalnik/gemlock)

Overview
--------

    $ rake gemlock:outdated
    rails is out of date!
    Installed version: 3.0.10. Latest version: 3.1.0

Gemlock looks at what gems you've specified in your Gemfile, checks the version
that that Bundler has set in Gemfile.lock, and lets you know if there's a newer
version available.

Installation
------------

1. Add `gem 'gemlock'` to your `Gemfile`
2. Run `bundle install`
3. If you're using Rails, you're done! Otherwise, add `require 'gemlock/rake_tasks'` to your Rakefile
