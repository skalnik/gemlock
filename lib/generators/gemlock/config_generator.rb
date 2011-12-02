require 'rails/generators'

module Gemlock
  class ConfigGenerator < Rails::Generators::Base
    argument :email, :type => :string, :default => 'email@example.com'
    source_root File.expand_path(File.join('..', '..', 'templates'), __FILE__)

    def generate_config
      template "config.yml.erb", "config/gemlock.yml"
    end
  end
end
