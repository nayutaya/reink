# coding: utf-8

require "rubygems"
require "log4r"

require File.join(File.dirname(__FILE__), "basic_client")
require File.join(File.dirname(__FILE__), "interval_client")
require File.join(File.dirname(__FILE__), "cached_client")

module HttpClient
  module Factory
    def self.create_client(options)
      options = options.dup
      logger   = options.delete(:logger)   || raise(ArgumentError, "logger")
      interval = options.delete(:interval) || nil
      store    = options.delete(:store)    || nil
      raise(ArgumentError, "invalid key -- " + options.keys.join(",")) unless options.empty?

      client = HttpClient::BasicClient.new(logger)
      client = HttpClient::IntervalClient.new(logger, client, interval) if interval
      client = HttpClient::CachedClient.new(logger, client, store) if store

      return client
    end
  end
end

if $0 == __FILE__
  formatter = Log4r::PatternFormatter.new(:pattern => "%d [%l] %M", :date_pattern => "%H:%M:%S")
  outputter = Log4r::StderrOutputter.new("", :formatter => formatter)
  logger = Log4r::Logger.new($0)
  logger.add(outputter)
  logger.level = Log4r::DEBUG

  require File.join(File.dirname(__FILE__), "memory_store")

  client = HttpClient::Factory.create_client(:logger => logger, :interval => 2.0, :store => HttpClient::MemoryStore.new)
  p client
  client.get("http://www.google.com")
  client.get("http://www.google.com")
end
