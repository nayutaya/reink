# coding: utf-8

require "uri"
require "rubygems"
require "log4r"

module HttpClient
  class CachedClient
  end
end

class HttpClient::CachedClient
  def initialize(logger, client, store)
    @logger = logger
    @client = client
    @store  = store
  end

  def get(url)
    value = @store.get(url)
    if value
      @logger.info("cache [#{url}]")
    else
      value = @client.get(url)
      @store.put(url, value)
    end
    return value
  end
end
