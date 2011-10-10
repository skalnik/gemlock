require "bundler"
require "rest_client"
require "json"
require "yaml"

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
      json_hash = JSON.parse(RestClient.get("http://rubygems.org/api/v1/gems/#{name}.json"))

      return json_hash["version"]
    end

    def outdated
      specs = {}
      locked_gemfile_specs.each do |spec|
        specs[spec.name] = spec.version.to_s
      end

      outdated = {}
      locked_gemfile_specs.each do |spec|
        latest_version = lookup_version(spec.name)
        if Gem::Version.new(latest_version) > Gem::Version.new(spec.version)
          outdated[spec.name] = latest_version
        end
        hash
      end

      return_hash = {}
      outdated.each_pair do |name, latest_version|
        return_hash[name] = { :latest => latest_version,
                              :current => specs[name] }
      end

      return_hash
    end

    def config_file
      config_file = nil
      config_file = if defined?(Rails)
                      Rails.root.join('config', 'gemlock.yml')
                    end
    end

    def parsed_config
      parsed_config = nil
      if(config_file)
        parsed_config = YAML.load_file(config_file)
      end
    end

    def difference(local_version, gem_version)
      lock_major, lock_minor, lock_patch = local_version.split('.')
      gem_major, gem_minor, gem_patch = gem_version.split('.')

      if gem_major > lock_major
        "major"
      elsif gem_minor > lock_minor
        "minor"
      elsif gem_patch>lock_patch
        "patch"
      end
    end
  end
end
