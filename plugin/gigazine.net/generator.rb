# coding: utf-8

require "digest/sha1"
require "rubygems"
require "nokogiri"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module Gigazine
  module Generator
    def self.generate(http, original_url)
      canonical_url = self.get_canonical_url(http, original_url)
      urls          = self.get_multiple_page_urls(http, canonical_url)

      articles = urls.map { |url, src|
        Parser.parse(http.get(url), url)
      }

      (articles[1..-1] || []).each { |article|
        articles[0][:body] << "<hr/>" << article[:body]
      }

      article = articles.first
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
      return url
    end

    def self.get_multiple_page_urls(http, url)
      return [url]
    end

    def self.create_filename(url, ext)
      return "gigazine_#{Digest::SHA1.hexdigest(url)[0, 20]}.#{ext}"
    end
  end
end
