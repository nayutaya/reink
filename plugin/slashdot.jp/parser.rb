# coding: utf-8

require "rubygems"
require "nokogiri"

module Slashdot
  module Parser
    def self.parse(src, url)
      {
        :url            => url,
        :title          => self.extract_title(src),
        :published_time => self.extract_published_time(src),
        :editor         => self.extract_editor(src),
        :department     => self.extract_department(src),
        :images         => [],
        :body           => self.extract_body(src),
        :comments       => self.extract_comments(src),
      }
    end

    def self.extract_title(src)
      doc = Nokogiri.HTML(src)
      return doc.xpath('//*[@id="articles"]//div[@class="title"]/h3/a/text()').text.strip
    end

    def self.extract_published_time(src)
      doc = Nokogiri.HTML(src)
      details = doc.xpath('//*[@id="articles"]//div[@class="details"]').text.strip
      raise("invalid format") unless /(\d+)年(\d+)月(\d+)日 +(\d+)時(\d+)分の掲載/ =~ details
      return Time.local($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
    end

    def self.extract_editor(src)
      doc = Nokogiri.HTML(src)
      return doc.xpath('//*[@id="articles"]//div[@class="details"]/a/text()').text.strip
    end

    def self.extract_department(src)
      doc = Nokogiri.HTML(src)
      details = doc.xpath('//*[@id="articles"]//div[@class="details"]').text.strip
      return details.split(/\s+/).last
    end

    def self.extract_body(src)
      doc = Nokogiri.HTML(src)

      # 全体の不要な要素を削除
      doc.xpath("//comment()").remove
      doc.xpath("//script").remove
      doc.xpath("//noscript").remove
      doc.xpath("//text()").
        select { |node| node.text.strip.empty? }.
        each   { |node| node.remove }

      intro = doc.xpath('//*[@id="articles"]//div[@class="intro"]').first
      intro.remove_attribute("class")
      full = doc.xpath('//*[@id="articles"]//div[@class="full"]').first
      full.remove_attribute("class") if full

      body  = intro.to_xml(:indent => 0, :encoding => "UTF-8")
      body += full.to_xml(:indent => 0, :encoding => "UTF-8") if full

      return body
    end

    def self.extract_comments(src)
      doc = Nokogiri.HTML(src)

      # 全体の不要な要素を削除
      doc.xpath("//comment()").remove
      doc.xpath("//script").remove
      doc.xpath("//noscript").remove
      doc.xpath("//text()").
        select { |node| node.text.strip.empty? }.
        each   { |node| node.remove }

      list = doc.xpath('//ul[@id="commentlisting"]')

      return self.extract_child_comments(list)
    end

    def self.extract_child_comments(list)
      # 不要なli要素を削除
      list.xpath('./li[@class="hide"]').remove
      # [コメントを書く]、[親コメント]などのリンクを削除
      list.xpath('.//span[@class="nbutton"]').remove
      # [n 個のコメント が現在のしきい値以下です。]を削除
      list.xpath('./li/b').each { |item| item.parent.remove }

      return list.xpath('./li').map { |item|
        title        = item.xpath('./div/div/div[@class="title"]/h4/a/text()').text.strip
        score        = item.xpath('./div/div/div[@class="title"]/h4/span//text()').text.strip.slice(1..-2)
        user         = item.xpath('./div/div/div[@class="details"]//text()').first.text.strip
        otherdetails = item.xpath('./div/div/div[@class="details"]/span[@class="otherdetails"]/text()').text.strip
        body         = item.xpath('./div/div[@class="commentBody"]/div').first
        children     = item.xpath('./ul').first

        raise("invalid format") unless /(\d+)年(\d+)月(\d+)日 +(\d+)時(\d+)分/ =~ otherdetails
        time = Time.local($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
        body.remove_attribute("id")

        {
          :title    => title,
          :score    => score,
          :user     => user,
          :time     => time,
          :body     => body.to_xml(:indent => 0, :encoding => "UTF-8"),
          :comments => (children ? self.extract_child_comments(children) : []),
        }
      }
    end
  end
end
