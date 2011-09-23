require "bundler"
require "rest_client"
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

    def lookup_version(name)
      json_hash = JSON.parse(RestClient.get("https://rubygems.org/api/v1/gems/#{name}.json"))

      return json_hash["version"]
    end

    def outdated
      specs = {}
      locked_gemfile_specs.each do |spec|
        specs[spec.name] = spec.version.to_s
      end

      oudated = {}
      locked_gemfile_specs.each do |spec|
        latest_version = lookup_version(spec.name)
        if Gem::Version.new(latest_version) > Gem::Version.new(spec.version)
          oudated[spec.name] = latest_version
        end
        hash
      end

      return_hash = {}
      oudated.each_pair do |name, latest_version|
        return_hash[name] = { :latest => latest_version,
                              :current => specs[name] }
      end

      return_hash
    end
  end
end
