# coding: utf-8

module Reink
  module Epub
    class MimeType
      def to_s
        return File.open(File.join(File.dirname(__FILE__), "mimetype"), "rb") { |file| file.read }
      end
    end
  end
end

if $0 == __FILE__
  mimetype = Reink::Epub::MimeType.new
  puts(mimetype.to_s)
end
