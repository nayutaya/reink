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

      def create_content_opf(meta, articles)
        content_opf = ContentOpf.new
        content_opf.uuid      = meta[:uuid]      || raise(ArgumentError, "uuid")
        content_opf.title     = meta[:title]     || raise(ArgumentError, "title")
        content_opf.author    = meta[:author]    || raise(ArgumentError, "author")
        content_opf.publisher = meta[:publisher] || nil
        content_opf.items    << {:id => "ID1", :href => "HREF1", :type => "TYPE1"}
        content_opf.items    << {:id => "ID2", :href => "HREF2", :type => "TYPE2"}
        content_opf.itemrefs << {:idref => "IDREF1"}
        content_opf.itemrefs << {:idref => "IDREF2"}
        return content_opf
      end

      def create_toc_ncx(meta, articles)
        toc_ncx = TocNcx.new
        toc_ncx.uuid   = meta[:uuid]   || raise(ArgumentError, "uuid")
        toc_ncx.title  = meta[:title]  || raise(ArgumentError, "title")
        toc_ncx.author = meta[:author] || raise(ArgumentError, "author")
        toc_ncx.nav_points << {:label_text => "LABEL-TEXT1", :content_src => "CONTENT-SRC1"}
        toc_ncx.nav_points << {:label_text => "LABEL-TEXT2", :content_src => "CONTENT-SRC2"}
        return toc_ncx
      end

      def create_toc_xhtml(meta, articles)
        toc_xhtml = TocXhtml.new
        toc_xhtml.items << {:href => "HREF1", :title => "TITLE1"}
        toc_xhtml.items << {:href => "HREF2", :title => "TITLE2"}
        return toc_xhtml
      end
    end
  end
end

if $0 == __FILE__
  meta     = {
    :uuid      => "META-UUID",
    :title     => "META-TITLE",
    :author    => "META-AUTHOR",
    :publisher => "META-PUBLISHER",
  }
  articles = []

  factory       = Reink::Epub::EpubFactory.new
  mimetype      = factory.create_mimetype
  container_xml = factory.create_container_xml
  content_opf   = factory.create_content_opf(meta, articles)
  toc_ncx       = factory.create_toc_ncx(meta, articles)
  toc_xhtml     = factory.create_toc_xhtml(meta, articles)

  #puts "---", mimetype
  #puts "---", container_xml
  puts "---", content_opf
  puts "---", toc_ncx
  puts "---", toc_xhtml
end
