require 'spec_helper'

describe Gemlock do
  describe "#locked_gemfile_specs" do
    it "outputs the list of gems & version requirements" do
      Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))

      specs = Gemlock.locked_gemfile_specs
      expected = [["coffee-rails", "3.1.0"], ["jquery-rails", "1.0.14"],
                  ["json",         "1.5.0"], ["rails",         "3.1.0"],
                  ["ruby-debug",  "0.10.4"], ["sass-rails",    "3.1.0"],
                  ["sqlite3",      "1.3.4"], ["uglifier",      "1.0.3"],
                  ["unicorn",      "4.1.0"]]

      specs.should match_name_and_versions_of expected
    end
  end

  describe "#lockfile" do
    it "loads Gemfile.lock from the Rails root if Rails is defined" do
      module Rails
        def self.root
          Pathname.new(File.expand_path('fixtures', File.dirname(__FILE__)))
        end
      end

      expected_path = Pathname.new(File.expand_path(File.join('fixtures', 'Gemfile.lock'),
                                                    File.dirname(__FILE__)))
      Gemlock.lockfile.should eql expected_path

      # Undefine Rails module
      Object.send(:remove_const, :Rails)
    end

    it "loads Gemfile.lock from the default Bundler location if Rails is not defined" do
      expected_path = Pathname.new(File.expand_path(File.join('spec', 'fixtures', 'Gemfile.lock')))

      Gemlock.lockfile.should eql expected_path
    end
  end

  describe "#lookup_version" do
    use_vcr_cassette

    it "looks up and return the latest version of a given gem" do
      version = Gemlock.lookup_version("rails")
      version.should eql "3.1.0"
    end
  end

  describe "#outdated" do
    use_vcr_cassette

    it "returns a hash of outdated gems & versions" do
      Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))

      expected = {'coffee-rails' => { :current => '3.1.0',
                                      :latest  => '3.1.1' },
                  'sass-rails'   => { :current => '3.1.0',
                                      :latest  => '3.1.2' },
                  'unicorn'      => { :current => '4.1.0',
                                      :latest  => '4.1.1' },
                  'json'         => { :current => '1.5.0',
                                      :latest  => '1.6.1' } }

      Gemlock.outdated.should eql expected
    end
  end

  describe "#config_file" do
    it "loads gemlock.yml from the config directory if Rails is defined" do
      module Rails
        def self.root
          Pathname.new(File.dirname(__FILE__))
        end
      end

      expected_path = Pathname.new(File.dirname(__FILE__)).join('config', 'gemlock.yml')
      Gemlock.config_file.should eql expected_path

      # Undefine Rails module
      Object.send(:remove_const, :Rails)

    end

    it "is nil if Rails is not defined" do
      Gemlock.config_file.should be_nil
    end
  end

  describe "#parsed_config" do
    it "returns nil if the config_file is not defined" do
      Gemlock.parsed_config.should be_nil
    end

    it "returns a hash containing the user's email if config_file is defined" do
      Gemlock.stubs(:config_file).returns((File.join(File.dirname(__FILE__), 'fixtures', 'gemlock.yml')))

      Gemlock.parsed_config["email"].should eql "tester@example.com"
    end
  end

  describe "#difference" do
    it "returns 'major' if there is a major version difference between the two gem versions" do
      Gemlock.difference("2.5.10", "3.1.0").should eql "major"
    end

    it "returns 'minor' if there is a minor version difference between the two gem versions" do
      Gemlock.difference("3.0.0", "3.1.0").should eql "minor"
    end

    it "returns 'patch' if there is a patch version difference between the two gem versions" do
      Gemlock.difference("3.1.0", "3.1.1").should eql "patch"
    end

  end
end
