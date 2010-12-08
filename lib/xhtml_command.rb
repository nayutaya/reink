# coding: utf-8

require "optparse"
require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "version")
require File.join(File.dirname(__FILE__), "plugin")
require File.join(File.dirname(__FILE__), "http", "factory")
require File.join(File.dirname(__FILE__), "http", "message_pack_store")

module Reink
  module XhtmlCommand
    def self.main(argv)
      params = self.parse_options(argv)
      logger = self.create_logger(params[:log_level])
      http   = self.create_http_client(logger, params[:interval])
      url    = params[:url]

      plugin    = Reink::Plugin.find_by_url(url) || raise("no such plugin for #{url}")
      generator = plugin[:generator].call
      article   = generator.generate(http, url)
      content   = article[:filebody]

      STDOUT.write(content)
    rescue RuntimeError => e
      self.abort(e)
    end

    def self.parse_options(argv)
      log_levels = [:off, :fatal, :error, :warn, :info, :debug]
      params = {
        :url       => nil,
        :interval  => 1.0,
        :log_level => :info,
      }
      OptionParser.new { |opt|
        opt.program_name = "reink xhtml"
        opt.version      = Reink::VERSION
        # TODO: -c --cache-dir=DIR を追加
        opt.on("-i", "--interval=SECOND", Float)      { |v| params[:interval]  = v }
        opt.on("-l", "--log-level=LEVEL", log_levels) { |v| params[:log_level] = v }
        opt.on("-v", "--verbose")                     { |v| params[:log_level] = :debug }
        opt.parse!(argv)
      }
      params[:url] = argv.shift || raise(OptionParser::MissingArgument, "url")
      return params
    rescue OptionParser::ParseError => e
      self.abort(e)
    end

    def self.abort(exception)
      name = File.basename($0, ".rb")
      STDERR.puts("#{name}: #{exception.message}")
      exit(1)
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

    def self.create_http_client(logger, interval)
      store = HttpClient::MessagePackStore.new(File.join(File.dirname(__FILE__), "..", "cache"))
      return HttpClient::Factory.create_client(
        :logger   => logger,
        :interval => interval,
        :store    => store)
    end
  end
end
