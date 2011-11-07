require 'gemlock'
require 'rails'

module Gemlock
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gemlock.rake'
    end

    initializer 'Check for updates using Gemlock' do
      Gemlock.initializer unless Rails.env.test?
    end
  end
end
