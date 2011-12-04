require 'spec_helper'

describe Gemlock::Config do
  describe ".file" do
    it "loads gemlock.yml from the config directory if Rails is defined" do
      module Rails
        def self.root
          Pathname.new(File.dirname(__FILE__))
        end
      end
      expected_path = Pathname.new(File.dirname(__FILE__)).join('config', 'gemlock.yml')
      File.stubs(:exists?).with(expected_path).returns(true)

      Gemlock::Config.file.should eql expected_path

      # Undefine Rails module
      Object.send(:remove_const, :Rails)

    end

    it "is nil if Rails is defined and the files does not exist" do
      module Rails
        def self.root
          Pathname.new(File.dirname(__FILE__))
        end
      end

      Gemlock::Config.parsed.should be_nil

      Object.send(:remove_const, :Rails)
    end

    it "is nil if Rails is not defined and the file exists" do
      Gemlock::Config.file.should be_nil
    end
  end

  describe ".parsed" do
    it "returns nil if the config file is not present" do
      Gemlock::Config.stubs(:file).returns(nil)
      Gemlock::Config.parsed.should be_nil
    end

    it "returns a hash containing the user's email if config file is present" do
      Gemlock::Config.stubs(:file).returns((File.join(File.dirname(__FILE__), '..', 'fixtures', 'gemlock.yml')))
      Gemlock::Config.parsed["email"].should eql "tester@example.com"
    end
  end

  describe ".email" do
    it "returns the email in the config if present and valid" do
      Gemlock::Config.stubs(:parsed).returns({'email' => 'hi@mikeskalnik.com'})
      Gemlock::Config.email.should eql 'hi@mikeskalnik.com'
    end

    it "returns nil if the email in the config is invalid" do
      Gemlock::Config.stubs(:parsed).returns({'email' => 'd@er@p.com'})
      Gemlock::Config.email.should be_nil
    end

    it "returns nil if there is no config" do
      Gemlock::Config.stubs(:parsed).returns(nil)
      Gemlock::Config.email.should be_nil
    end
  end

  describe ".update_interval" do
    it "returns the number of seconds in a week if config_file is not present, or interval is not specified" do
      Gemlock::Config.update_interval.should eql 60*60*24*7

      Gemlock::Config.stubs(:parsed).returns({"email"=>"tester@example.com"})
      Gemlock::Config.update_interval.should eql 60*60*24*7
    end

    it "returns the number of seconds until the next number of hours as given" do
      Gemlock::Config.stubs(:parsed).returns({"interval" => ["8 hours"]})
      Gemlock::Config.update_interval.should eql 60*60*8
    end

    it "returns the number of seconds until the next number of days as given" do
      Gemlock::Config.stubs(:parsed).returns({"interval" => ["4 days"]})
      Gemlock::Config.update_interval.should eql 60*60*24*4
    end

    it "returns the number of seconds until the next number of weeks as given" do
      Gemlock::Config.stubs(:parsed).returns({"interval" => ["2 weeks"]})
      Gemlock::Config.update_interval.should eql 60*60*24*7*2
    end

    it "returns the number of seconds unil the next number of months as given" do
      Gemlock::Config.stubs(:parsed).returns({"interval" => ["3 months"]})
      Gemlock::Config.update_interval.should eql 60*60*24*30*3
    end
  end
end
