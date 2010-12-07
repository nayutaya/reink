
require "digest/sha1"
require "rubygems"
require "msgpack"

module HttpClient
  class MessagePackStore
  end
end

class HttpClient::MessagePackStore
  def initialize(dir)
    @dir = dir
  end

  def get(url)
    filepath = create_cache_filepath(url)
    cache = self.load_cache(filepath)
    return cache[url]
  end

  def put(url, value)
    filepath = create_cache_filepath(url)
    cache = self.load_cache(filepath)
    cache[url] = value
    self.save_cache(filepath, cache)
  end

  def create_cache_filepath(url)
    return File.join(@dir, Digest::SHA1.hexdigest(url)[0, 2] + ".mp")
  end

  def load_cache(filepath)
    if File.exist?(filepath)
      binary = File.open(filepath, "rb") { |file| file.read }
      return MessagePack.unpack(binary)
    else
      return {}
    end
  end

  def save_cache(filepath, cache)
    binary = MessagePack.pack(cache)
    File.open(filepath, "wb") { |file| file.write(binary) }
  end
end
