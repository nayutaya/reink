# coding: utf-8

require "digest/md5"
require File.join(File.dirname(__FILE__), "article_parser")
require File.join(File.dirname(__FILE__), "article_formatter")

module TechOn
  module Article
    def self.get(http, url)
      curl    = self.get_canonical_url(http, url)
      src     = http.get(curl)
      article = ArticleParser.extract(src, curl)

      article["images"].each { |image|
        filename, type =
          case image["url"]
          when /\.jpg$/i then [Digest::MD5.hexdigest(image["url"]) + ".jpg", "image/jpeg"]
          else raise("unknown type")
          end
        image["file"]     = http.get(image["url"])
        image["filename"] = filename
        image["type"]     = type
      }

      article["file"]     = ArticleFormatter.format(article)
      article["filename"] = Digest::MD5.hexdigest(article["url"]) + ".xhtml"
      article["type"]     = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      return $1 if /\A(.+)\?ref=rss\z/ =~ url
      return url
    end
  end
end
