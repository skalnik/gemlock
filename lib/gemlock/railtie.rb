require 'gemlock'
require 'rails'

module Gemlock
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gemlock.rake'
    end

    initializer 'Check for updates using Gemlock' do
      Gemlock.initializer if Rails.env.production?
    end
  end
end
