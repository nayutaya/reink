# coding: utf-8

module Reink
  module Epub
    class MimeType
      def initialize
        @body = File.open(File.join(File.dirname(__FILE__), "mimetype"), "rb:utf-8") { |file| file.read }
      end

      def to_s
        return @body
      end
    end
  end
end

if $0 == __FILE__
  mimetype = Reink::Epub::MimeType.new
  puts(mimetype.to_s)
end
