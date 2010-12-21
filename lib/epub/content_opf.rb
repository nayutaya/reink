# coding: utf-8

require "erb"

module Reink
  module Epub
    class ContentOpf
      include ERB::Util

      def initialize
        @uuid      = nil
        @title     = nil
        @author    = nil
        @publisher = nil
        @items     = []
        @itemrefs  = []

        @template = File.open(File.join(File.dirname(__FILE__), "content.opf.erb"), "rb") { |file| file.read }
      end

      attr_accessor :uuid, :title, :author, :publisher, :items, :itemrefs

      def to_s
        return ERB.new(@template, nil, "-").result(binding)
      end
    end
  end
end

if $0 == __FILE__
  content_opf = Reink::Epub::ContentOpf.new
  content_opf.uuid      = "UUID"
  content_opf.title     = "TITLE"
  content_opf.author    = "AUTHOR"
  content_opf.publisher = "PUBLISHER"
  content_opf.items    << {:id => "ID", :href => "HREF", :type => "TYPE"}
  content_opf.itemrefs << {:idref => "IDREF"}
  puts(content_opf.to_s)
end
