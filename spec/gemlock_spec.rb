require 'spec_helper'

describe Gemlock do
  describe ".locked_gemfile_specs" do
    it "outputs the list of gems & version requirements" do
      Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))

      specs = Gemlock.locked_gemfile_specs
      expected = [["coffee-rails", "3.1.0"], ["jquery-rails", "1.0.16"],
                  ["json",         "1.5.0"], ["rails",         "3.1.0"],
                  ["ruby-debug",  "0.10.4"], ["sass-rails",    "3.1.0"],
                  ["sqlite3",      "1.3.4"], ["uglifier",      "1.0.4"],
                  ["unicorn",      "3.1.0"]]

      specs.should match_name_and_versions_of expected
    end
  end

  describe ".lockfile" do
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

  describe ".lookup_version" do
    use_vcr_cassette

    it "looks up and return the latest version of a given gem" do
      version = Gemlock.lookup_version("rails")
      version.should eql "3.1.1"
    end
  end

  describe ".check_gems_individually" do
    use_vcr_cassette

    it "returns a hash of outdated gems & versions specificed in config" do
      Gemlock::Config.stubs(:file).returns((File.join(File.dirname(__FILE__), 'fixtures', 'gemlock.yml')))

      gems = Gemlock.locked_gemfile_specs.inject({}) do |hash, spec|
        hash[spec.name] = spec.version.to_s
        hash
      end

      expected = {'coffee-rails' => { :current => '3.1.0',
                                      :latest  => '3.1.1' },
                  'sass-rails'   => { :current => '3.1.0',
                                      :latest  => '3.1.4' },
                  'unicorn'      => { :current => '3.1.0',
                                      :latest  => '4.1.1' },
                  'rails'        => { :current => '3.1.0',
                                      :latest  => '3.1.1'} }

      Gemlock.check_gems_individually(gems).should eql expected
    end
  end

  describe ".outdated" do
    use_vcr_cassette

    before do
      Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))
    end

    let(:in_spec) { {"coffee-rails" => "3.1.0",
                     "jquery-rails" => "1.0.16",
                     "json"         => "1.5.0",
                     "rails"        => "3.1.0",
                     "ruby-debug"   => "0.10.4",
                     "sass-rails"   => "3.1.0",
                     "sqlite3"      => "1.3.4",
                     "uglifier"     => "1.0.4",
                     "unicorn"      => "3.1.0"} }

    it "returns a hash of all outdated gems" do
      expected = {'coffee-rails' => { :current => '3.1.0',
                                      :latest  => '3.1.1' },
                  'sass-rails'   => { :current => '3.1.0',
                                      :latest  => '3.1.5' },
                  'unicorn'      => { :current => '3.1.0',
                                      :latest  => '4.1.1' },
                  'json'         => { :current => '1.5.0',
                                      :latest  => '1.6.3' },
                  'rails'        => { :current => '3.1.0',
                                      :latest  => '3.1.3'},
                  'jquery-rails' => { :current => '1.0.16',
                                      :latest  => '1.0.19'},
                  'sqlite3'      => { :current => '1.3.4',
                                      :latest  => '1.3.5'},
                  'uglifier'     => { :current => '1.0.4',
                                      :latest  => '1.1.0'} }

      Gemlock.outdated.should eql expected
    end

    it "checks for each gem individually if the bulk check fails" do
      RestClient.expects(:get).with("http://gemlock.herokuapp.com/ruby_gems/updates.json",
                                   {:params => {:gems      => in_spec.to_json,
                                                :interval  => 60*60*24*7*2}}).raises(RestClient::GatewayTimeout)
      Gemlock.expects(:check_gems_individually).with(in_spec)

      Gemlock.outdated
    end

    it "sets an flag if it is an automatic check" do
      RestClient.expects(:get).with("http://gemlock.herokuapp.com/ruby_gems/updates.json",
                                    {:params => {:gems      => in_spec.to_json,
                                                 :automatic => true,
                                                 :interval  => 60*60*24*7*2}}).returns('{}')

      Gemlock.outdated(true)
    end

    it "sends the email address in config to the server if present" do
      Gemlock::Config.stubs(:parsed).returns({'email' => 'hi@mikeskalnik.com'})
      RestClient.expects(:get).with("http://gemlock.herokuapp.com/ruby_gems/updates.json",
                                    {:params => {:gems  => in_spec.to_json,
                                                 :email => 'hi@mikeskalnik.com',
                                                 :interval => 60*60*24*7*2}}).returns('{}')

      Gemlock.outdated
    end

    it "sends the application name in config to the server if present" do
      Gemlock::Config.stubs(:parsed).returns({'name' => 'Gemlock'})
      RestClient.expects(:get).with("http://gemlock.herokuapp.com/ruby_gems/updates.json",
                                    {:params => {:gems     => in_spec.to_json,
                                                 :app_name => 'Gemlock',
                                                 :interval => 60*60*24*7*2}}).returns('{}')
      Gemlock.outdated
    end

    it "sends the update interval in config to the server if present" do
      Gemlock::Config.stubs(:parsed).returns({'interval' => ['2 weeks']})
      RestClient.expects(:get).with("http://gemlock.herokuapp.com/ruby_gems/updates.json",
                                    {:params => {:gems     => in_spec.to_json,
                                                 :interval => 60*60*24*7*2}}).returns('{}')
      Gemlock.outdated
    end
  end


  describe ".difference" do
    it "returns 'major' if there is a major version difference between the two gem versions" do
      Gemlock.difference("2.0.0",  "3.0.0").should eql "major"
      Gemlock.difference("2.5.10", "3.1.0").should eql "major"
      Gemlock.difference("3.1.10", "2.5.8").should eql "major"
      Gemlock.difference("3.0",    "2.0"  ).should eql "major"
    end

    it "returns 'minor' if there is a minor version difference between the two gem versions" do
      Gemlock.difference("3.0.0", "3.1.0").should eql "minor"
      Gemlock.difference("3.1.0", "3.2.1").should eql "minor"
      Gemlock.difference("3.1.0", "3.0.0").should eql "minor"
    end

    it "returns 'patch' if there is a patch version difference between the two gem versions" do
      Gemlock.difference("3.1.0", "3.1.1").should eql "patch"
      Gemlock.difference("0.0.2", "0.0.1").should eql "patch"
    end

    it "returns 'none' if there is no difference" do
      Gemlock.difference("0.0.0", "0.0.0").should eql "none"
      Gemlock.difference("0.0.1", "0.0.1").should eql "none"
      Gemlock.difference("0.1.0", "0.1.0").should eql "none"
      Gemlock.difference("1.0.0", "1.0.0").should eql "none"
    end
  end

  describe '.initializer' do
    it "makes a thread" do
      Gemlock.stubs(:outdated).returns([])

      capture_stdout do
        @thread = Gemlock.initializer

        @thread.class.should eql Thread
        @thread.kill
      end
    end

    it "checks for updates" do
      Gemlock.expects(:outdated).returns([])

      capture_stdout do
        @thread = Gemlock.initializer

        while @thread.status != 'sleep' do
          sleep 0.5
        end
        @thread.kill
      end
    end
  end

  describe ".process_version" do
    it "splits a version string into an array" do
      Gemlock.send(:process_version, "3.0.0").class.should eql Array
    end

    it "appends missing zeros to the end of a version if not given" do
      Gemlock.send(:process_version, "3").should eql [3, 0, 0]
      Gemlock.send(:process_version, "3.0").should eql [3, 0, 0]
    end
  end

  def capture_stdout
    io = StringIO.new
    $stdout = io
    yield
    return io
  ensure
    $stdout = STDOUT
  end
end
