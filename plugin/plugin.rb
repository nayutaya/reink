# coding: utf-8

module Reink
  module Plugin
    Plugins = []
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "*", "manifest.rb")).sort.each { |manifest|
  require(manifest)
}

p Reink::Plugin::Plugins
