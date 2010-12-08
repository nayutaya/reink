# coding: utf-8

module Reink
  module Plugin
    Plugins = []
  end
end

plugin_dir = File.join(File.dirname(__FILE__), "..", "plugin")
manifests  = Dir.glob(File.join(plugin_dir, "*", "manifest.rb"))
manifests.sort.each { |manifest|
  require(manifest)
}
