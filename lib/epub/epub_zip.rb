# coding: utf-8

require "rubygems"
require "zip"

module Reink
  module Epub
    class EpubZip
      def initialize
        @entries = []
      end

      def add(filename, content)
        @entries << {:filename => filename, :content => content}
      end

      def write(filename)
        File.unlink(filename) if File.exist?(filename)
        Zip::File.open(filename, Zip::File::CREATE) { |zip|
          @entries.each { |entry|
            zip.get_output_stream(entry[:filename]) { |io|
              io.write(entry[:content])
            }
          }
        }
      end
    end
  end
end

if $0 == __FILE__
  zip = Reink::Epub::EpubZip.new
  zip.add("a.txt", "aaa")
  zip.add("b.txt", "bbb")
  zip.add("dir/c.txt", "ccc")
  zip.write("tmp.zip")
  p zip
end
