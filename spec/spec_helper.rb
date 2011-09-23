require 'rubygems'
require 'bundler'

begin
  Bundler.require(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

RSpec.configure do |config|
  config.mock_with :mocha
end

VCR.config do |c|
  c.cassette_library_dir = File.expand_path(File.join('fixtures', 'vcr_cassettes'), File.dirname(__FILE__))
  c.stub_with :fakeweb
  c.default_cassette_options = { :record => :once }
end

