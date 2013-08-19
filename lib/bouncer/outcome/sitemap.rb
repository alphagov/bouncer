module Bouncer
  module Outcome
    class Sitemap < Base
      def serve
        [200, { 'Content-Type' => 'application/xml' }, [build_sitemap.to_xml]]
      end

      def build_sitemap
        Nokogiri::XML::Builder.new do |xml|
          xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
            context.mappings.where("http_status like '3%'").each do |mapping|
              url = URI.parse(mapping.path).tap do |uri|
                uri.scheme = 'http'
                uri.host   = context.request.host
              end

              xml.url do
                xml.loc url
              end
            end
          end
        end
      end

    end
  end
end
