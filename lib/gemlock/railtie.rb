require 'gemlock'
require 'rails'

module Gemlock
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gemlock.rake'
    end

    initializer 'Check for updates using Gemlock' do
      unless Rails.env.test?
        Gemlock.initializer(Rails.env.production?)
      end
    end
  end
end
