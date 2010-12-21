# coding: utf-8

module Reink
  module Epub
    class MimeType
      def to_s
        return DATA.read
      end
    end
  end
end

if $0 == __FILE__
  mimetype = Reink::Epub::MimeType.new
  puts(mimetype.to_s)
end

__END__
application/epub+zip
