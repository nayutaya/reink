#! ruby -Ku
# coding: utf-8

require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "..", "lib", "http", "factory")
require File.join(File.dirname(__FILE__), "..", "lib", "http", "message_pack_store")
require File.join(File.dirname(__FILE__), "..", "plugin", "plugin")

def create_http_client(logger)
  #store = HttpClient::MessagePackStore.new(File.join(File.dirname(__FILE__), "..", "cache"))
  store = nil
  return HttpClient::Factory.create_client(
    :logger   => logger,
    :interval => 1.0,
    :store    => store)
end

def create_logger
  formatter = Log4r::PatternFormatter.new(:pattern => "%d [%l] %M", :date_pattern => "%H:%M:%S")
  outputter = Log4r::StderrOutputter.new("", :formatter => formatter)
  logger = Log4r::Logger.new($0)
  logger.add(outputter)
  logger.level = Log4r::DEBUG
  return logger
end

logger = create_logger
http   = create_http_client(logger)

#p Reink::Plugin::Plugins

url = "http://www.asahi.com/international/update/1208/TKY201012070526.html"

plugin = Reink::Plugin::Plugins.find { |params| params[:url_pattern] =~ url }
article = plugin[:generator].call(logger, http, url)


STDOUT.write(article[:filebody])
