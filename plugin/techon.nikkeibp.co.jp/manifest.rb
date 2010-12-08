# coding: utf-8

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://techon\.nikkeibp\.co\.jp/.+|,
  :generator   => proc {
    require(File.join(File.dirname(__FILE__), "generator"))
    TechOn::Generator
  },
}
