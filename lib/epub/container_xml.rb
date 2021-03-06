# coding: utf-8

module Reink
  module Epub
    class ContainerXml
      def initialize
        @body = File.open(File.join(File.dirname(__FILE__), "container.xml"), "rb:utf-8") { |file| file.read }
      end

      def to_s
        return @body
      end
    end
  end
end

if $0 == __FILE__
  container_xml = Reink::Epub::ContainerXml.new
  puts(container_xml.to_s)
end
