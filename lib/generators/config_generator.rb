require 'rails/generators'

class ConfigGenerator < Rails::Generators::Base
  def create_config_file
    create_file "config/gemlock.yml"
  end
end