require 'gemlock'
require 'rails'

module Gemlock
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gemlock.rake'
    end
  end
end
