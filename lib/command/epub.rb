# coding: utf-8

require "optparse"
require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "..", "version")

module Reink
  module Command
    module Epub
      LogLevels = [:off, :fatal, :error, :warn, :info, :debug].freeze
      DefaultOptions = {
        :manifest  => nil,
        :url_list  => nil,
        :output    => nil,
        :title     => nil,
        :author    => nil,
        :publisher => nil,
        :uuid      => nil,
        :cache_dir => nil,
        :interval  => 1.0,
        :log_level => :info,
      }.freeze

      def self.main(argv)
        options = self.parse_options(argv)
        p options
      rescue RuntimeError => e
        self.abort(e)
      end

      def self.parse_options(argv)
        options = DefaultOptions.dup
        OptionParser.new { |opt|
          opt.program_name = "reink #{File.basename(__FILE__, '.rb')}"
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
      rescue OptionParser::ParseError => e
        self.abort(e)
      end

      def self.abort(exception)
        STDERR.puts("reink #{File.basename(__FILE__, '.rb')}: #{exception.message}")
        exit(1)
      end
    end
  end
end
