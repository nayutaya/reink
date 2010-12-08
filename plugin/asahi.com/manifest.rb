# coding: utf-8

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://www\.asahi\.com/.+|,
  :generator   => proc {
    require File.join(File.dirname(__FILE__), "generator")
    Asahi::Generator
  },
}
