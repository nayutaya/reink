# coding: utf-8

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://slashdot\.jp/.+|,
  :generator   => proc {
    require File.join(File.dirname(__FILE__), "generator")
    Slashdot::Generator
  },
}
