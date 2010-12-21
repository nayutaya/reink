# coding: utf-8

require "erb"

module Reink
  module Epub
    class TocNcx
      include ERB::Util

      def initialize
        @uuid       = nil
        @title      = nil
        @author     = nil
        @nav_points = []

        @template = File.open(File.join(File.dirname(__FILE__), "toc.ncx.erb"), "rb") { |file| file.read }
      end

      attr_accessor :uuid, :title, :author, :nav_points

      def to_s
        return ERB.new(@template, nil, "-").result(binding)
      end
    end
  end
end

if $0 == __FILE__
  toc_ncx = Reink::Epub::TocNcx.new
  toc_ncx.uuid   = "UUID"
  toc_ncx.title  = "TITLE"
  toc_ncx.author = "AUTHOR"
  toc_ncx.nav_points << {:label_text => "LABEL-TEXT1", :content_src => "CONTENT-SRC1"}
  toc_ncx.nav_points << {:label_text => "LABEL-TEXT2", :content_src => "CONTENT-SRC2"}
  puts(toc_ncx.to_s)
end
