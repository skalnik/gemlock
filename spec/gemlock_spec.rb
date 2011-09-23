require 'spec_helper'

describe "gemlock methods" do
  it "should check if gems are outdated" do
    Gemlock.stubs(:lockfile).returns((File.join(File.dirname(__FILE__), 'fixtures', 'Gemfile.lock')))
    VCR.use_cassette('rails_cassette') do
      request = Gemlock.request_gem_data("rails")
    end 
    expected = {"name"=>"rails",
                "version"=>"3.0.1"} 
    request["version"].should be > expected["version"]
  end 

  it "should request data from rubygems.org and return a hash" do
    VCR.use_cassette('rails_cassette') do
      request = Gemlock.request_gem_data("rails")
    end 
    expected ={ "name"=>"rails", 
                "version"=>"3.1.0", 
                "wiki_uri"=>"http://wiki.rubyonrails.org"}  

    request["name"].should eql expected["name"]
    request["version"].should eql expected["version"]
  end 
end
