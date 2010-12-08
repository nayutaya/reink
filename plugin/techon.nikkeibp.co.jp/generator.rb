# coding: utf-8

require "digest/md5"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module TechOn
  module Generator
    def self.generate(http, url)
      curl    = self.get_canonical_url(http, url)
      src     = http.get(curl)
      article = Parser.extract(src, curl)

      article[:images].each { |image|
        filename, type =
          case image[:url]
          when /\.jpg$/i then [Digest::MD5.hexdigest(image[:url]) + ".jpg", "image/jpeg"]
          else raise("unknown type")
          end
        image[:filebody] = http.get(image[:url])
        image[:filename] = filename
        image[:filetype] = type
      }

      article[:filebody] = Formatter.format(article)
      article[:filename] = Digest::MD5.hexdigest(article[:url]) + ".xhtml"
      article[:filetype] = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      return $1 if /\A(.+)\?ref=rss\z/ =~ url
      return url
    end
  end
end
