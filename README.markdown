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

If you're using Gemlock in a Rails project, whenever you start your server,
Gemlock will check for updates. Then, it will check again in 2 weeks or when
you restart your server, whichever comes first. In the future, both of these
should be configurable options.

Installation
------------

1. Add `gem 'gemlock'` to your `Gemfile`
2. Run `bundle install`
3. If you're using Rails, you're done! Otherwise, add `require 'gemlock/rake_tasks'` to your Rakefile

Configuration
-------------

Configuration options should be placed in the file config/gemlock.yml. Currently
Gemlock does not auto-create this file, so for the moment you will need to create
the file by hand. The only configuration options that are used currently are the 
'interval' field which tells Gemlock how often to check for updates, and the 
'releases' field which lets the user specify what types of gem updates they would
like to be notified about. An example of gemlock.yml would look like:

    releases:
      -minor
      -patch
    interval:
      - 2 weeks
