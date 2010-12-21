# coding: utf-8

module Reink
  module Environment
    def self.get_home_dir
      case RUBY_PLATFORM
      when /win32/
        dir = ENV["HOMEDRIVE"] + ENV["HOMEPATH"]
        raise("home not found") unless File.directory?(dir)
        return File.expand_path(dir)
      else
        raise("unknown platform")
      end
    end

    def self.get_nayutaya_base_dir
      dir = File.join(self.get_home_dir, ".nayutaya")
      Dir.mkdir(dir) unless File.exist?(dir)
      return dir
    end

    def self.get_base_dir
      dir = File.join(self.get_nayutaya_base_dir, "reink")
      Dir.mkdir(dir) unless File.exist?(dir)
      return dir
    end

    def self.get_cache_dir
      dir = File.join(self.get_base_dir, "cache")
      Dir.mkdir(dir) unless File.exist?(dir)
      return dir
    end
  end
end

if $0 == __FILE__
  p Reink::Environment.get_home_dir
  p Reink::Environment.get_nayutaya_base_dir
  p Reink::Environment.get_base_dir
  p Reink::Environment.get_cache_dir
end
