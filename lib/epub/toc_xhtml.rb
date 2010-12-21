# coding: utf-8

require "erb"

module Reink
  module Epub
    class TocXhtml
      include ERB::Util

      def initialize
        @items = []

        @template = File.open(File.join(File.dirname(__FILE__), "toc.xhtml.erb"), "rb") { |file| file.read }
      end

      attr_accessor :items

      def to_s
        return ERB.new(@template, nil, "-").result(binding)
      end
    end
  end
end

if $0 == __FILE__
  toc_xhtml = Reink::Epub::TocXhtml.new
  toc_xhtml.items << {:href => "HREF", :title => "TITLE"}
  toc_xhtml.items << {:href => "HREF", :title => "TITLE"}
  puts(toc_xhtml.to_s)
end
