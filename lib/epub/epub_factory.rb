# coding: utf-8

require File.join(File.dirname(__FILE__), "mimetype")
require File.join(File.dirname(__FILE__), "container_xml")
require File.join(File.dirname(__FILE__), "content_opf")
require File.join(File.dirname(__FILE__), "toc_ncx")
require File.join(File.dirname(__FILE__), "toc_xhtml")

module Reink
  module Epub
    class EpubFactory
      def create_mimetype
        return MimeType.new
      end

      def create_container_xml
        return ContainerXml.new
      end

      def create_content_opf(articles)
        return ContentOpf.new
      end

      def create_toc_ncx(articles)
        return TocNcx.new
      end

      def create_toc_xhtml(articles)
        return TocXhtml.new
      end
    end
  end
end

if $0 == __FILE__
  factory = Reink::Epub::EpubFactory.new
  puts "---"
  puts factory.create_mimetype
  puts "---"
  puts factory.create_container_xml
  puts "---"
  puts factory.create_content_opf(nil)
  puts "---"
  puts factory.create_toc_ncx(nil)
  puts "---"
  puts factory.create_toc_xhtml(nil)
end
