# coding: utf-8

require "erb"

module Slashdot
  module Formatter
    def self.format(article)
      filename = File.join(File.dirname(__FILE__), "template.xhtml.erb")
      template = File.open(filename, "rb") { |file| file.read }

      comments = self.format_comments(article[:comments])

      env = Object.new
      env.extend(ERB::Util)
      env.instance_eval {
        @url            = article[:url]
        @title          = article[:title]
        @published_time = article[:published_time]
        @editor         = article[:editor]
        @department     = article[:department]
        @body           = article[:body]
        @comments       = comments
      }

      erb = ERB.new(template, nil, "-")
      erb.filename = filename

      return erb.result(env.instance_eval { binding })
    end

    def self.format_comments(comments, nest = 1)
      return comments.map { |comment|
        self.format_comment(comment, nest)
      }.join("")
    end

    def self.format_comment(comment, nest)
      filename = File.join(File.dirname(__FILE__), "comment.xhtml.erb")
      template = File.open(filename, "rb") { |file| file.read }

      children =
        if comment[:comments].empty?
          nil
        else
          self.format_comments(comment[:comments], nest + 1)
        end

      env = Object.new
      env.extend(ERB::Util)
      env.instance_eval {
        @nest     = nest
        @title    = comment[:title]
        @score    = comment[:score]
        @user     = comment[:user]
        @time     = comment[:time]
        @body     = comment[:body]
        @children = children
      }

      erb = ERB.new(template, nil, "-")
      erb.filename = filename

      return erb.result(env.instance_eval { binding })
    end
  end
end
