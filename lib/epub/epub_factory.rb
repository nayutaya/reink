# coding: utf-8

module Reink
  module Epub
    class EpubFactory
    end
  end
end

if $0 == __FILE__
  factory = Reink::Epub::EpubFactory.new
  p factory
end
