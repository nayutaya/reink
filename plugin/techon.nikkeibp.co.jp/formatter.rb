# coding: utf-8

require "erb"

module TechOn
  module ArticleFormatter
    def self.format(article)
      filename = File.join(File.dirname(__FILE__), "template.xhtml.erb")
      template = File.open(filename, "rb") { |file| file.read }

      env = Object.new
      env.extend(ERB::Util)
      env.instance_eval {
        @url            = article["url"]
        @title          = article["title"]
        @published_time = article["published_time"]
        @author         = article["author"]
        @images         = article["images"]
        @body           = article["body"]
      }

      erb = ERB.new(template, nil, "-")
      erb.filename = filename

      return erb.result(env.instance_eval { binding })
    end
  end
end
