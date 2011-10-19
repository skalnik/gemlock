require 'gemlock'
require 'rails'

module Gemlock
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/gemlock.rake'
    end

    initializer 'Check for updates using Gemlock' do
      puts "Checking for gem updates..."
      outdated = Gemlock.outdated
      if outdated.empty?
        puts "All gems up to date!"
      else
        outdated.each_pair do |name, versions|
          puts "#{name} is out of date!"
          puts "Installed version: #{versions[:current]}. Latest version: #{versions[:latest]}"
          puts "To update: bundle update #{name}"
        end
        puts ""
        puts "To update all your gems via bundler:"
        puts "bundle update"
      end
    end
  end
end
