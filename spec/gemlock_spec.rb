require 'spec_helper'

describe Gemlock do
  describe "#locked_gemfile_specs" do
    it "should output the list of gems & version requirements" do
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
    it "should load Gemfile.lock from the Rails root if Rails is defined" do
      module Rails
        def self.root
          Pathname.new(File.dirname(__FILE__))
        end
      end

      expected_path = Pathname.new(File.dirname(__FILE__)).join('Gemfile.lock')
      Gemlock.lockfile.should eql expected_path
    end

    it "should load Gemfile.lock from the default Bundler location if Rails is not defined" do
      expected_path = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), 'Gemfile.lock')))

      Gemlock.lockfile.should eql expected_path
    end
  end

  describe "#lookup_version" do
    it "should look up and return the latest version of a given gem" do
      VCR.use_cassette('rails_cassette') do
        version = Gemlock.lookup_version("rails")
        version.should eql "3.1.0"
      end
    end
  end

  describe "#outdated" do
    it "should return an array of outdated gem specifications" do
      Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))

      VCR.use_cassette('outdated_cassette') do
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
  end
end
