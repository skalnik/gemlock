require "bundler"

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
        begin
          response = RestClient.get "https://rubygems.org/api/v1/gems/#{spec.name}.json"
        rescue => e
          e.response
         end

        result = JSON.parse(response)

        gem_version = result["version"]

        if(gem_version>spec.version.to_s)
          #Gem is out of date
        else
          #Gem is not out of date
        end     
      end
    end
  end
end
