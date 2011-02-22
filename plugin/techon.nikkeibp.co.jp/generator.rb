# coding: utf-8

require "digest/sha1"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module TechOn
  module Generator
    def self.generate(http, original_url)
      canonical_url = self.get_canonical_url(http, original_url)
      urls          = self.get_multiple_page_urls(http, canonical_url)

      articles = urls.map { |url, src|
        Parser.parse(http.get(url), url)
      }

      articles[0][:images]          ||= []
      articles[0][:internal_images] ||= []

      (articles[1..-1] || []).each { |article|
        articles[0][:body] << "<hr/>" << article[:body]
        articles[0][:images]          += article[:images]          || []
        articles[0][:internal_images] += article[:internal_images] || []
      }

      articles[0][:images].uniq!
      articles[0][:internal_images].uniq!

      images = []
      images += articles[0][:images]
      images += articles[0][:internal_images]

      images.each { |image|
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

=begin
      images.each { |image|
        body.xpath("//img").
          select { |img| img[:src] == image[:url] }.
          each   { |img| img.set_attribute("src", image[:filename]) }
      }
=end

      article = articles.first
      article[:filebody] = Formatter.format(article)
      article[:filename] = self.create_filename(article[:url], "xhtml")
      article[:filetype] = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      return $1 if /\A(.+)\?ref=rss\z/ =~ url
      return url
    end

    def self.get_multiple_page_urls(http, url)
      src = http.get(url)
      doc = Nokogiri.HTML(src)

      urls  = [url]
      urls += doc.xpath('//*[@id="pageNumber"]//a').
        map { |anchor| anchor[:href] }.
        map { |path| URI.join(url, path).to_s }

      return urls.uniq
    end

    def self.create_filename(url, ext)
      return "techon_#{Digest::SHA1.hexdigest(url)[0, 20]}.#{ext}"
    end
  end
end

if $0 == __FILE__
  require "open-uri"
  require "pp"
  http = Object.new
  def http.get(url)
    return open(url) { |io| io.read }
  end

  p url1 = "http://techon.nikkeibp.co.jp/article/NEWS/20110218/189699/?ref=rss"
  p url2 = TechOn::Generator.get_canonical_url(http, url1)
  #pp TechOn::Generator.get_multiple_page_urls(http, url2)
  src = http.get(url2)
  pp internal_images = TechOn::Parser.extract_internal_images(src, url2)
end
