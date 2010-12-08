# coding: utf-8

require "optparse"
require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "version")
require File.join(File.dirname(__FILE__), "http", "factory")
require File.join(File.dirname(__FILE__), "http", "message_pack_store")
require File.join(File.dirname(__FILE__), "..", "plugin", "plugin")

module Reink
  module XhtmlCommand
    LOG_LEVELS = [:off, :fatal, :error, :warn, :info, :debug]

    def self.main(argv)
      params = {:log_level => :info}
      opts = OptionParser.new
      opts.version = Reink::VERSION
      opts.on("-l", "--log-level LEVEL", LOG_LEVELS) { |v| params[:log_level] = v }
      opts.parse!(argv)

      p params

      logger = self.create_logger(params[:log_level])
      http   = self.create_http_client(logger)

      #p Reink::Plugin::Plugins

      url = "http://www.asahi.com/international/update/1208/TKY201012070526.html"
      #url = "http://www.asahi.com/international/update/1207/TKY201012070409.html?ref=reca"

      plugin = Reink::Plugin::Plugins.find { |params| params[:url_pattern] =~ url }
      article = plugin[:generator].call(logger, http, url)

#      STDOUT.write(article[:filebody])
    rescue OptionParser::InvalidArgument => e
      name = File.basename($0, ".rb")
      STDERR.puts("#{name}: #{e.message}")
    end

    def self.create_http_client(logger)
      store = HttpClient::MessagePackStore.new(File.join(File.dirname(__FILE__), "..", "cache"))
      return HttpClient::Factory.create_client(
        :logger   => logger,
        :interval => 1.0,
        :store    => store)
    end

    def self.create_logger(log_level)
      formatter = Log4r::PatternFormatter.new(:pattern => "%d [%l] %M", :date_pattern => "%H:%M:%S")
      outputter = Log4r::StderrOutputter.new("", :formatter => formatter)
      logger = Log4r::Logger.new($0)
      logger.add(outputter)
      logger.level =
        case log_level
        when :off   then Log4r::OFF
        when :fatal then Log4r::FATAL
        when :error then Log4r::ERROR
        when :warn  then Log4r::WARN
        when :info  then Log4r::INFO
        when :debug then Log4r::DEBUG
        end
      return logger
    end
  end
end
