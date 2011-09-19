require 'spec_helper'

describe "rake tasks" do
  it "output the list of gems & version requirements" do
    Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))

    specs = Gemlock.locked_gemfile_specs.inject([]) { |a, spec| a << [spec.name, spec.version.to_s]}
    expected = [["coffee-rails", "3.1.1"], ["jquery-rails", "1.0.14"],
                ["json",         "1.6.1"], ["rails",         "3.1.0"],
                ["ruby-debug",  "0.10.4"], ["sass-rails",    "3.1.2"],
                ["sqlite3",      "1.3.4"], ["uglifier",      "1.0.3"],
                ["unicorn",      "4.1.1"]]

    specs.should eql expected
  end

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
