# coding: utf-8

require "uri"
require "rubygems"
require "log4r"

module HttpClient
  class IntervalClient
  end
end

class HttpClient::IntervalClient
  def initialize(logger, client, interval)
    @logger   = logger
    @client   = client
    @interval = interval
    @table    = {}
  end

  def get(url)
    host = URI.parse(url).host.downcase

    now   = Time.now
    last  = @table[host] || (Time.now - @interval.ceil)
    @logger.debug("last access [#{host}] in #{last.strftime('%Y-%m-%d %H:%M:%S')}")

    delta = now - last - @interval
    if delta < 0
      @logger.info("sleep #{-delta} sec")
      sleep(-delta)
    end

    ret = @client.get(url)

    @table[host] = Time.now

    return ret
  end
end
