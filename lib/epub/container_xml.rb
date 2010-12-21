# coding: utf-8

module Reink
  module Epub
    class ContainerXml
      def to_s
        return DATA.read
      end
    end
  end
end

if $0 == __FILE__
  container_xml = Reink::Epub::ContainerXml.new
  puts(container_xml.to_s)
end

__END__
<?xml version="1.0" encoding="UTF-8"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
 <rootfiles>
  <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
 </rootfiles>
</container>
