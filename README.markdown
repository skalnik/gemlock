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
you restart your server, whichever comes first. If you specify an email in the
configuration file, you'll also get notified when these automatic checks run and
gem updates are found.

Installation
------------

1. Add `gem 'gemlock'` to your `Gemfile`
2. Run `bundle install`
3. If you're using Rails, you're done! Otherwise, add `require 'gemlock/rake_tasks'` to your Rakefile

Configuration
-------------

Gemlock is can be customized to suit your neeeds. Just run `rails generate
gemlock:config` to generate a sample config with a few options:

  * `releases` - What kind of releases you'd like to know about (e.g. `major`, `minor`, `patch`)
  * `interval` - How often you'd like to check for updates
  * `email`    - An email address to email if updates are found while automatic checks
  * `name`     - The name of your application

An example file would look like:

    releases:
      - minor
      - patch
    interval: 2 weeks
    email: hi@mikeskalnik.com
