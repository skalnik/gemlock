require "bundler"

require "json"

require "gemlock/version"

module Gemlock
  require 'gemlock/railtie' if defined?(Rails)

  class << self
    def lockfile
      @lockfile ||= if defined?(Rails)
                      Rails.root.join('Gemfile.lock')
                    else
                      Bundler::SharedHelpers.default_lockfile
                    end
    end

    def locked_gemfile_specs
      locked_content = Bundler.read_file(lockfile)
      locked = Bundler::LockfileParser.new(locked_content)

      gemfile_names = locked.dependencies.map(&:name)
      locked_gemfile_specs = locked.specs.clone
      locked_gemfile_specs.delete_if { |spec| !gemfile_names.include?(spec.name) }
    end

    def outdated_gems
      locked_gemfile_specs.each do |spec|

        json_result = request_gem_data(spec.name)
        gem_version = json_result["version"]

        if(gem_version>spec.version.to_s)
          #Gem is out of date
        else
          #Gem is not out of date
        end    
      end 
    end 

    def request_gem_data(name)
      response = RestClient.get "https://rubygems.org/api/v1/gems/#{name}.json"
      result = JSON.parse(response)

      return result
    end 
  end
end
