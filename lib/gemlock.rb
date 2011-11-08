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
      json_hash = JSON.parse(RestClient.get("http://gemlock.herokuapp.com/ruby_gems/#{name}/latest.json"))

      return json_hash["version"]
    end

    def outdated
      specs = {}
      locked_gemfile_specs.each do |spec|
        specs[spec.name] = spec.version.to_s
      end

      response = JSON.parse(RestClient.get("http://gemlock.herokuapp.com/ruby_gems/updates.json", {:params => {:gems => specs.to_json}}))

      response.inject({}) do |hash, gem|
        name, version = *gem
        hash[name] = {:latest => version, :current => specs[name]}
        hash
      end
    end

    def difference(version_a, version_b)
      major_a, minor_a, patch_a = process_version(version_a)
      major_b, minor_b, patch_b = process_version(version_b)

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
    def initializer
      update_interval = Gemlock.update_interval
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

    def update_interval
      if parsed_config
        if parsed_config["interval"]
          interval = parsed_config["interval"][0]

          num_hours = interval.match(/\d*/)[0].to_i
          if interval =~ /hour/
            delay = 60*60
          elsif interval =~ /day/
            delay = 60*60*24
          elsif interval =~ /week/
            delay = 60*60*24*7
          elsif interval =~ /month/
            delay = 60*60*24*30
          end
          if delay && num_hours > 0
            delay *= num_hours
            return delay
          elsif delay
            return delay
          end
        end
      end
      60*60*24*7 #Seconds in a week
    end

    def check_gems_individually(gems)
      outdated = {}

      gems.each_pair do |name, version|
        latest_version = lookup_version(name)
        update_type = difference(version, latest_version)
        if Gem::Version.new(latest_version) > Gem::Version.new(version)
          if parsed_config.nil? || parsed_config['releases'].include?(update_type)
            outdated[name] = latest_version
          end
        end
      end

      outdated.inject({}) do |hash, gem|
        name, version = *gem
        hash[name] = { :latest => version, :current => gems[name] }
        hash
      end
    end

  private

    def process_version(version_string)
      version = version_string.split('.').collect(&:to_i)

      if version.length < 3
        (3 - version.length).times do
          version << 0
        end
      end

      version
    end

    def sleep(length)
      Kernel.sleep(length)
    end
  end
end
