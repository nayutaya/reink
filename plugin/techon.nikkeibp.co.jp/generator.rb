# coding: utf-8

require "digest/sha1"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module TechOn
  module Generator
    def self.generate(http, url)
      curl    = self.get_canonical_url(http, url)
      src     = http.get(curl)
      article = Parser.extract(src, curl)

      article[:images].each { |image|
        image_url = image[:url]
        ext, type =
          case image_url
          when /\.jpg$/i then ["jpg", "image/jpeg"]
          else raise("unknown type")
          end
        image[:filebody] = http.get(image_url)
        image[:filename] = self.create_filename(image_url, ext)
        image[:filetype] = type
      }

      article[:filebody] = Formatter.format(article)
      article[:filename] = self.create_filename(article[:url], "xhtml")
      article[:filetype] = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      return $1 if /\A(.+)\?ref=rss\z/ =~ url
      return url
    end

    def self.create_filename(url, ext)
      return "techon_#{Digest::SHA1.hexdigest(url)[0, 20]}.#{ext}"
    end
  end
end
