# coding: utf-8

module Reink
  module Environment
    def self.get_home_dir
      case RUBY_PLATFORM
      when /win32/
        path = ENV["HOMEDRIVE"] + ENV["HOMEPATH"]
        return File.expand_path(path)
      else
        raise("unknown platform")
      end
    end
  end
end

if $0 == __FILE__
  p Reink::Environment.get_home_dir
end
