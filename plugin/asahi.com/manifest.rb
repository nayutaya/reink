# coding: utf-8

generator = proc { |logger, http, url|
  require File.join(File.dirname(__FILE__), "generator")
  article = Asahi::Generator.generate(http, url)
  article
}

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://www\.asahi\.com/.+|,
  :generator   => generator,
}
