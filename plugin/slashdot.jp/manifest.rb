# coding: utf-8

generator = proc { |logger, http, url|
  require File.join(File.dirname(__FILE__), "generator")
  article = Slashdot::Generator.generate(http, url)
  article
}

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://slashdot\.jp/.+|,
  :generator   => generator,
}
