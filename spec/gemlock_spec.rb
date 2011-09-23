require 'spec_helper'

describe Gemlock do
  it "should look up and return the latest version of a given gem" do
    VCR.use_cassette('rails_cassette') do
      version = Gemlock.lookup_version("rails")
      version.should eql "3.1.0"
    end
  end
end
