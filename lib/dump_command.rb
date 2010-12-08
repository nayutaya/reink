# coding: utf-8

require "optparse"
require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "version")
require File.join(File.dirname(__FILE__), "plugin")
require File.join(File.dirname(__FILE__), "http", "factory")
require File.join(File.dirname(__FILE__), "http", "message_pack_store")

module Reink
  module DumpCommand
    def self.main(argv)
      options    = self.parse_options(argv)
      url        = options[:url]
      output_dir = options[:output_dir]
      interval   = options[:interval]
      log_level  = options[:log_level]

      logger = self.create_logger(log_level)
      http   = self.create_http_client(logger, interval)

      plugin    = Reink::Plugin.find_by_url(url) || raise("no such plugin for #{url}")
      generator = plugin[:generator].call
      article   = generator.generate(http, url)

      self.write_body(logger, article, output_dir)
      self.write_images(logger, article, output_dir)
    rescue RuntimeError => e
      self.abort(e)
    end

    def self.parse_options(argv)
      options = {
        :url        => nil,
        :output_dir => ".",
        :interval   => 1.0,
        :log_level  => :info,
      }

      log_levels = [:off, :fatal, :error, :warn, :info, :debug]
      OptionParser.new { |opt|
        opt.version = Reink::VERSION
        # TODO: -c --cache-dir=DIR を追加
        opt.on("-o", "--output-dir=DIR", String)      { |v| options[:output_dir] = v }
        opt.on("-i", "--interval=SECOND", Float)      { |v| options[:interval]   = v }
        opt.on("-l", "--log-level=LEVEL", log_levels) { |v| options[:log_level]  = v }
        opt.on("-v", "--verbose")                     { |v| options[:log_level]  = :debug }
        opt.parse!(argv)
      }

      options[:url] = argv.shift || raise(OptionParser::MissingArgument, "url")

      raise("no such directory -- #{options[:output_dir]}") unless File.directory?(options[:output_dir])

      return options
    rescue RuntimeError, OptionParser::ParseError => e
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

    def self.write_body(logger, article, output_dir)
      filename = File.join(output_dir, article[:filename])
      File.open(filename, "wb") { |file|
        file.write(article[:filebody])
      }
      logger.info("wrote #{filename}")
    end

    def self.write_images(logger, article, output_dir)
      article[:images].each { |image|
        filename = File.join(output_dir, image[:filename])
        File.open(filename, "wb") { |file|
          file.write(image[:filebody])
        }
        logger.info("wrote #{filename}")
      }
    end
  end
end
