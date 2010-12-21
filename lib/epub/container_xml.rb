# coding: utf-8

module Reink
  module Epub
    class ContainerXml
      def to_s
        return File.open(File.join(File.dirname(__FILE__), "container.xml"), "rb") { |file| file.read }
        return DATA.read
      end
    end
  end
end

if $0 == __FILE__
  container_xml = Reink::Epub::ContainerXml.new
  puts(container_xml.to_s)
end
