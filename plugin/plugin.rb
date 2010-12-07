# coding: utf-8

module Reink
  module Plugin
    Plugins = []
  end
end

plugin_dir = File.dirname(__FILE__)
manifests  = Dir.glob(File.join(plugin_dir, "*", "manifest.rb"))
manifests.sort.each { |manifest|
  require(manifest)
}
