# coding: utf-8

namespace :cache do
  desc "cleanup cache"
  task :clean do
    Dir.glob(File.join(File.dirname(__FILE__), "cache", "??.mp")).
      sort.
      select { |path| /^[0-9a-f]{2}\.mp$/i =~ File.basename(path) }.
      each   { |path| File.unlink(path) }
  end
end
