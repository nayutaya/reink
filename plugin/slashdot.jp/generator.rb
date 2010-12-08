# coding: utf-8

require "cgi"
require "uri"
require "digest/sha1"
require "rubygems"
require "nokogiri"
require File.join(File.dirname(__FILE__), "parser")
require File.join(File.dirname(__FILE__), "formatter")

module Slashdot
  module Generator
    def self.generate(http, url)
      canonical_url = self.get_canonical_url(http, url)
      commented_url = self.get_commented_url(canonical_url)
      src           = http.get(commented_url)
      article       = Parser.parse(src, commented_url)

      article[:filebody] = Formatter.format(article)
      article[:filename] = self.create_filename(article[:url], ".xhtml")
      article[:filetype] = "application/xhtml+xml"

      return article
    end

    def self.get_canonical_url(http, url)
      src = http.get(url)
      doc = Nokogiri.HTML(src)
      return doc.xpath("/html/head/link[@rel='canonical']").first[:href]
    end

    def self.get_commented_url(url)
      return self.merge_query(url,
        "threshold"   => "1",      # 閾値: 1
        "mode"        => "nested", # ネストする
        "commentsort" => "0")      # 古い順
    end

    def self.parse_query(query)
      return query.split("&").
        map { |pair| raise unless /^(.+?)=(.+?)$/ =~ pair; [$1, $2] }.
        map { |key, value| [CGI.unescape(key), CGI.unescape(value)] }.
        inject({}) { |memo, (key, value)| memo[key] = value; memo }
    end

    def self.build_query(params)
      return params.
        sort_by { |key, value| key }.
        map { |key, value| [CGI.escape(key), CGI.escape(value)] }.
        map { |key, value|  "#{key}=#{value}" }.
        join("&")
    end

    def self.merge_query(url, params)
      uri = URI.parse(url)
      uri.query = self.build_query(self.parse_query(uri.query).merge(params))
      return uri.to_s
    end

    def self.create_filename(url, ext)
      return "slashdot_#{Digest::SHA1.hexdigest(url)[0, 20]}.#{ext}"
    end
  end
end
