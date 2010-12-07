# coding: utf-8

generator = proc { |logger, http, url|
  p [logger, http, url]
}

Reink::Plugin::Plugins << {
  :url_pattern => %r|http://www\.asahi\.com/.+|,
  :generator   => generator,
}
