# coding: utf-8

require "digest/md5"
require "rubygems"
require "nokogiri"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module Asahi
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
        image[:filename] = "asahi#{Digest::MD5.hexdigest(image_url)}.#{ext}"
        image[:filetype] = type
      }

      article[:filebody] = Formatter.format(article)
      article[:filename] = "asahi#{Digest::MD5.hexdigest(article[:url])}.xhtml"
      article[:filetype] = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      src = http.get(url)
      doc = Nokogiri.HTML(src)
      return doc.xpath("/html/head/link[@rel='canonical']").first[:href]
    end

    def self.get_multiple_page_urls(http, url)
      src = http.get(url)
      doc = Nokogiri.HTML(src)

      urls  = [url]
      urls += doc.xpath('//*[@id="HeadLine"]/div/ol/li').
        map { |item| item.xpath('./a').first }.
        compact.
        map { |anchor| anchor[:href] }.
        map { |path| URI.join(url, path).to_s }

      return urls.uniq
    end
  end
end
