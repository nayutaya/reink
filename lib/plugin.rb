# coding: utf-8

module Reink
  module Plugin
    Plugins = []

    def self.load_plugins
      plugin_dir = File.join(File.dirname(__FILE__), "..", "plugin")
      manifests  = Dir.glob(File.join(plugin_dir, "*", "manifest.rb"))
      manifests.sort.each { |manifest|
        require(manifest)
      }
    end

    def self.find_by_url(url)
      return Plugins.find { |plugin| plugin[:url_pattern] =~ url }
    end
  end
end

Reink::Plugin.load_plugins
