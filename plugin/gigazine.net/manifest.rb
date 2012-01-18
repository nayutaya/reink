# coding: utf-8

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://gigazine\.net/.+|,
  :generator   => proc {
    require(File.join(File.dirname(__FILE__), "generator"))
    Gigazine::Generator
  },
}
