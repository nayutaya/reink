# coding: utf-8

require "optparse"
require "yaml"
require "rubygems"
require "log4r"
require "uuid"
require File.join(File.dirname(__FILE__), "..", "version")
require File.join(File.dirname(__FILE__), "..", "plugin")
require File.join(File.dirname(__FILE__), "..", "http", "factory")
require File.join(File.dirname(__FILE__), "..", "http", "message_pack_store")
require File.join(File.dirname(__FILE__), "..", "epub", "epub_factory")

module Reink
  module Command
    module Epub
      CommandName = File.basename(__FILE__, ".rb")
      LogLevels = [:off, :fatal, :error, :warn, :info, :debug].freeze

      def self.main(argv)
        options = self.parse_options(argv)
        self.merge_manifest!(options)
        self.validate_options!(options)

        options[:output]    ||= "output.epub"
        options[:interval]  ||= 1.0
        options[:log_level] ||= :info

        logger = self.create_logger(options[:log_level])
        http   = self.create_http_client(logger, options[:interval])

        meta     = self.create_meta(options)
        urls     = self.get_urls(options)
        articles = self.get_articles(http, urls)
        self.write_epub(meta, articles, options[:output])
        logger.info("wrote #{options[:output]}")
      rescue RuntimeError, OptionParser::ParseError => e
        self.abort(e)
      end

      def self.abort(exception)
        STDERR.puts("reink #{CommandName}: #{exception.message}")
        exit(1)
      end

      def self.parse_options(argv)
        options = {}
        OptionParser.new { |opt|
          opt.program_name = "reink #{CommandName}"
          opt.version      = Reink::VERSION
          opt.on("-m", "--manifest=FILE",       String)    { |v| options[:manifest]  = v }
          opt.on("-u", "--url-list=FILE",       String)    { |v| options[:url_list]  = v }
          opt.on("-o", "--output=FILE",         String)    { |v| options[:output]    = v }
          opt.on("-t", "--title=STRING",        String)    { |v| options[:title]     = v }
          opt.on("-a", "--author=STRING",       String)    { |v| options[:author]    = v }
          opt.on("-p", "--publisher=STRING",    String)    { |v| options[:publisher] = v }
          opt.on("-U", "--uuid=UUID",           String)    { |v| options[:uuid]      = v }
          opt.on("-c", "--cache-dir=DIRECTORY", String)    { |v| options[:cache_dir] = v }
          opt.on("-i", "--interval=SECOND",     Float)     { |v| options[:interval]  = v }
          opt.on("-l", "--log-level=LEVEL",     LogLevels) { |v| options[:log_level] = v }
          opt.on("-v", "--verbose")                        { |v| options[:log_level] = :debug }
          opt.parse!(argv)
        }
        return options
      end

      def self.merge_manifest!(options)
        return unless options[:manifest]
        manifest = YAML.load_file(options[:manifest])

        m_url_list  = manifest.delete("url-list")
        m_output    = manifest.delete("output")
        m_title     = manifest.delete("title")
        m_author    = manifest.delete("author")
        m_publisher = manifest.delete("publisher")
        m_uuid      = manifest.delete("uuid")
        raise("unknown manifest keys -- #{manifest.keys.join(',')}") unless manifest.empty?

        options[:url_list]  ||= m_url_list
        options[:output]    ||= m_output
        options[:title]     ||= m_title
        options[:author]    ||= m_author
        options[:publisher] ||= m_publisher
        options[:uuid]      ||= m_uuid
      end

      def self.validate_options!(options)
        raise("no such manifest file -- #{options[:manifest]}") if options[:manifest] && !File.exist?(options[:manifest])
        raise("no such url list file -- #{options[:url_list]}") if options[:url_list] && !File.exist?(options[:url_list])
        raise("no such cache directory -- #{options[:cache_dir]}") if options[:cache_dir] && !File.directory?(options[:cache_dir])
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
        store = HttpClient::MessagePackStore.new(File.join(File.dirname(__FILE__), "..", "..", "cache"))
        return HttpClient::Factory.create_client(
          :logger   => logger,
          :interval => interval,
          :store    => store)
      end

      def self.create_meta(options)
        return {
          :uuid      => (options[:uuid]      || UUID.new.generate),
          :title     => (options[:title]     || Time.now.strftime("%Y-%m-%d %H:%M:%S")),
          :author    => (options[:author]    || "Unknown"),
          :publisher => (options[:publisher] || nil),
        }
      end

      def self.get_urls(options)
        if options[:url_list]
          return File.foreach(options[:url_list]).
            map { |line| line.strip }.
            reject { |line| line.empty? }
        else
          raise("missing urls")
        end
      end

      def self.get_articles(http, urls)
        text_id  = 0
        image_id = 0

        return urls.
          map { |url| [url, Reink::Plugin.find_by_url(url) || raise("no such plugin for #{url}")] }.
          map { |url, plugin| [url, plugin[:generator].call] }.
          map { |url, generator| generator.generate(http, url) }.
          each { |article|
            article[:id] = "t#{text_id += 1}"
            (article[:images] || []).each { |image|
              image[:id] = "i#{image_id += 1}"
            }
          }
      end

      def self.write_epub(meta, articles, filename)
        factory = Reink::Epub::EpubFactory.new
        zip = factory.create_zip(meta, articles)
        zip.write(filename)
      end
    end
  end
end
