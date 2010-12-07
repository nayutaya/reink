# coding: utf-8

module HttpClient
  class MemoryStore
  end
end

class HttpClient::MemoryStore
  def initialize
    @cache = {}
  end

  def get(url)
    return @cache[url]
  end

  def put(url, value)
    @cache[url] = value
  end
end
