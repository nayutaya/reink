# coding: utf-8

require "open-uri"
require "rubygems"
require "log4r"

module HttpClient
  class BasicClient
  end
end

class HttpClient::BasicClient
  def initialize(logger)
    @logger = logger
  end

  def get(url)
    @logger.info("get [#{url}]")
    # FIXME: net/httpを使う
    return open(url) { |io| io.read }
  end
end
