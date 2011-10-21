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

    def config
      if defined?(Rails) && File.exists?(Rails.root.join('config', 'gemlock.yml'))
        Rails.root.join('config', 'gemlock.yml')
      end
    end

    def parsed_config
      YAML.load_file(config) if config
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
        update_type = difference(spec.version.to_s, latest_version)
        if Gem::Version.new(latest_version) > Gem::Version.new(spec.version)
          if parsed_config.nil? || parsed_config['releases'].include?(update_type)
            outdated[spec.name] = latest_version
          end
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

    def difference(version_a, version_b)
      major_a, minor_a, patch_a = version_a.split('.').collect(&:to_i)
      major_b, minor_b, patch_b = version_b.split('.').collect(&:to_i)

      if (major_a - major_b).abs > 0
        "major"
      elsif (minor_a - minor_b).abs > 0
        "minor"
      elsif (patch_a - patch_b).abs > 0
        "patch"
      else
        "none"
      end
    end

    # By default, check for updates every 2 weeks
    def initializer(update_interval = 60*60*24*7*2)
      Thread.new(update_interval) do |interval|
        loop do
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
          puts "Checking for updates again in #{interval} seconds"
          sleep interval
        end
      end
    end
  end
end
