require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', File.dirname(__FILE__))
Bundler.require(:default, ENV['RACK_ENV'])
require File.expand_path('./settings', File.dirname(__FILE__))

Logging.logger.root.appenders = Logging.appenders.stdout

Raygun.setup do |config|
  # config.api_key = Settings.raygun.api_key
  # config.enable_reporting = ENV['RACK_ENV'] != 'development'
end
