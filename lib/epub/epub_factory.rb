# coding: utf-8

require File.join(File.dirname(__FILE__), "mimetype")
require File.join(File.dirname(__FILE__), "container_xml")
require File.join(File.dirname(__FILE__), "content_opf")
require File.join(File.dirname(__FILE__), "toc_ncx")
require File.join(File.dirname(__FILE__), "toc_xhtml")
require File.join(File.dirname(__FILE__), "epub_zip")

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

        articles.each { |article|
          content_opf.items << {
            :id   => (article[:id]       || raise(ArgumentError, "article/id")),
            :href => (article[:filename] || raise(ArgumentError, "article/filename")),
            :type => (article[:filetype] || raise(ArgumentError, "article/filetype")),
          }

          images = article[:images] || []
          images.each { |image|
            content_opf.items << {
              :id   => (image[:id]       || raise(ArgumentError, "article/image/id")),
              :href => (image[:filename] || raise(ArgumentError, "article/image/filename")),
              :type => (image[:filetype] || raise(ArgumentError, "article/image/filetype")),
            }
          }
        }

        articles.each { |article|
          content_opf.itemrefs << {
            :idref => (article[:id] || raise(ArgumentError, "article/id")),
          }
        }

        return content_opf
      end

      def create_toc_ncx(meta, articles)
        toc_ncx = TocNcx.new
        toc_ncx.uuid   = meta[:uuid]   || raise(ArgumentError, "uuid")
        toc_ncx.title  = meta[:title]  || raise(ArgumentError, "title")
        toc_ncx.author = meta[:author] || raise(ArgumentError, "author")

        articles.each { |article|
          toc_ncx.nav_points << {
            :label_text  => (article[:title]    || raise(ArgumentError, "article/title")),
            :content_src => (article[:filename] || raise(ArgumentError, "article/filename")),
          }
        }

        return toc_ncx
      end

      def create_toc_xhtml(meta, articles)
        toc_xhtml = TocXhtml.new

        articles.each { |article|
          toc_xhtml.items << {
            :title => (article[:title]    || raise(ArgumentError, "article/title")),
            :href  => (article[:filename] || raise(ArgumentError, "article/filename")),
          }
        }

        return toc_xhtml
      end

      def create_zip(meta, articles)
        mimetype      = self.create_mimetype
        container_xml = self.create_container_xml
        content_opf   = self.create_content_opf(meta, articles)
        toc_ncx       = self.create_toc_ncx(meta, articles)
        toc_xhtml     = self.create_toc_xhtml(meta, articles)

        zip = EpubZip.new
        zip.add("mimetype",               mimetype.to_s)
        zip.add("META-INF/container.xml", container_xml.to_s)
        zip.add("OEBPS/content.opf",      content_opf.to_s)
        zip.add("OEBPS/toc.ncx",          toc_ncx.to_s)
        zip.add("OEBPS/toc.xhtml",        toc_xhtml.to_s)

        articles.each { |article|
          zip.add("OEBPS/" + article[:filename], article[:filebody])
          images = article[:images] || []
          images.each { |image|
            zip.add("OEBPS/" + image[:filename], image[:filebody])
          }
        }

        return zip
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
  articles = [
    {
      :id       => "id1",
      :title    => "title1",
      :filebody => "filebody1",
      :filename => "filename1",
      :filetype => "type1",
      :images   => [
        {
          :id       => "image-id1",
          :filebody => "image-filebody1",
          :filename => "image-filename1",
          :filetype => "image-type1",
        },
        {
          :id       => "image-id2",
          :filebody => "image-filebody2",
          :filename => "image-filename2",
          :filetype => "image-type2",
        },
      ],
    },
    {
      :id       => "id2",
      :title    => "title2",
      :filebody => "filebody2",
      :filename => "filename2",
      :filetype => "type2",
    },
  ]

  factory = Reink::Epub::EpubFactory.new
  zip = factory.create_zip(meta, articles)
  zip.write("tmp.zip")
  p zip
end
