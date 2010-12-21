# coding: utf-8

require "optparse"
require "rubygems"
require "log4r"
require File.join(File.dirname(__FILE__), "..", "version")

module Reink
  module Command
    module Epub
      def self.main(argv)
        params = self.parse_options(argv)
        p params
      rescue RuntimeError => e
        self.abort(e)
      end

      def self.parse_options(argv)
        log_levels = [:off, :fatal, :error, :warn, :info, :debug]
        params = {
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
        }
        OptionParser.new { |opt|
          opt.program_name = "reink #{File.basename(__FILE__, '.rb')}"
          opt.version      = Reink::VERSION
          opt.on("-m", "--manifest=FILE",       String)     { |v| params[:manifest]  = v }
          opt.on("-u", "--url-list=FILE",       String)     { |v| params[:url_list]  = v }
          opt.on("-o", "--output=FILE",         String)     { |v| params[:output]    = v }
          opt.on("-t", "--title=STRING",        String)     { |v| params[:title]     = v }
          opt.on("-a", "--author=STRING",       String)     { |v| params[:author]    = v }
          opt.on("-p", "--publisher=STRING",    String)     { |v| params[:publisher] = v }
          opt.on("-U", "--uuid=UUID",           String)     { |v| params[:uuid]      = v }
          opt.on("-c", "--cache-dir=DIRECTORY", String)     { |v| params[:cache_dir] = v }
          opt.on("-i", "--interval=SECOND",     Float)      { |v| params[:interval]  = v }
          opt.on("-l", "--log-level=LEVEL",     log_levels) { |v| params[:log_level] = v }
          opt.on("-v", "--verbose")                         { |v| params[:log_level] = :debug }
          opt.parse!(argv)
        }
        return params
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
